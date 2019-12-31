/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2019 Tango Golf Digital, LLC
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Igis

open class Layer {

    internal private(set) var wasSetup : Bool
    internal private(set) var neverCalculated : Bool
    internal private(set) weak var mostRecentMouseDownEntity : RenderableEntityBase?
    private var backToFrontList : ZOrderedList<RenderableEntityBase>

    public private(set) weak var owner : Scene?

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    
    public init() {
        wasSetup = false
        neverCalculated = true
        mostRecentMouseDownEntity = nil
        backToFrontList = ZOrderedList<RenderableEntityBase>()

        owner = nil
    }

    internal func internalSetup(canvas:Canvas, scene:Scene) {
        precondition(!wasSetup, "Request to setup layer after already being setup")
        precondition(neverCalculated, "Request to setup layer after already being calculated")
        precondition(owner == nil, "Request to setup layer but owner is not nil")
        
        owner = scene

        // Setup all entities
        preSetup(canvas:canvas)
        for entity in backToFrontList.list {
            entity.internalSetup(canvas:canvas, layer:self)
        }
        postSetup(canvas:canvas)

        wasSetup = true
    }

    internal func internalCalculate(canvas:Canvas, scene:Scene) {
        // Layers added after the initial setup may not yet have been setup
        // We therefore check again now
        if !wasSetup {
            internalSetup(canvas:canvas, scene:scene)
        }

        precondition(wasSetup, "Request to calculate layer prior to setup")
        precondition(owner != nil, "Request to calculate layer but owner is nil")

        // Calculate all entities
        preCalculate(canvas:canvas)
        for entity in backToFrontList.list {
            entity.internalCalculate(canvas:canvas, layer:self)
        }
        postCalculate(canvas:canvas)

        neverCalculated = false
    }

    internal func internalRender(canvas:Canvas, scene:Scene) {
        // Layers added after the initial setup may not yet have been calculated (or setup)
        // We therefore check again now
        if neverCalculated {
            internalCalculate(canvas:canvas, scene:scene)
        }

        precondition(wasSetup, "Request to render layer prior to setup")
        precondition(owner != nil, "Request to render layer but owner is nil")
        precondition(!neverCalculated, "Request to render layer but never calculated")

        // Render all entities
        preRender(canvas:canvas)
        for entity in backToFrontList.list {
            entity.internalRender(canvas:canvas, layer:self)
        }
        postRender(canvas:canvas)
    }

    internal func internalOnMouseDown(location:Point) -> Layer? {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseDown prior to setup")
        precondition(owner != nil, "Request to process onMouseDown but owner is nil")

        // Also, there must not be a mostRecentMouseDownEntity
        precondition(mostRecentMouseDownEntity == nil, "Request to process onMouseDown but mostRecentMouseDownEntity is not nil")

        let frontToBackList = backToFrontList.list.reversed()
        for entity in frontToBackList {
            if entity.wasSetup {
                let desiredMouseEvents = entity.wantsMouseEvents()
                if desiredMouseEvents.contains(.downUp) || desiredMouseEvents.contains(.click) {
                    if entity.hitTest(location:location) {
                        entity.internalOnMouseDown(location:location)
                        mostRecentMouseDownEntity = entity
                        return self
                    }
                }
            }
        }

        // No entity was eligible in this layer for a mouseDown
        return nil
    }

    internal func internalOnMouseClick(location:Point) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseClick prior to setup")
        precondition(owner != nil, "Request to process onMouseClick but owner is nil")

        // Also, there must be a mostRecentMouseDownEntity
        guard let mostRecentMouseDownEntity = mostRecentMouseDownEntity else {
            fatalError("Request to process onMouseClick but mostRecentMouseDownEntity is nil")
        }

        if mostRecentMouseDownEntity.wantsMouseEvents().contains(.click) {
            mostRecentMouseDownEntity.internalOnMouseClick(location:location)
        }

        // Terminate the mostRecentMouseDownEntity
        self.mostRecentMouseDownEntity = nil
    }

    internal func internalOnMouseUp(location:Point) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseUp prior to setup")
        precondition(owner != nil, "Request to process onMousUp but owner is nil")

        // Also, there must not be a mostRecentMouseDownEntity
        precondition(mostRecentMouseDownEntity != nil, "Request to process onMouseUp but mostRecentMouseDownEntity is not nil")

        let frontToBackList = backToFrontList.list.reversed()
        for entity in frontToBackList {
            if entity.wasSetup {
                let desiredMouseEvents = entity.wantsMouseEvents()
                if desiredMouseEvents.contains(.downUp)  {
                    if entity.hitTest(location:location) {
                        entity.internalOnMouseUp(location:location)
                        return
                    }
                }
            }
        }
    }

    
    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************
    public func insert(entity:RenderableEntityBase, at zLocation:ZOrder<RenderableEntityBase>) {
        backToFrontList.insert(object:entity, at:zLocation)
    }

    public func moveZ(of entity:RenderableEntityBase, to zLocation:ZOrder<RenderableEntityBase>) {
        backToFrontList.moveZ(of:entity, to:zLocation)
    }

    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    // This function is invoked when mouse actions occur
    // Unless the function is overridden to return the desired mouseEvents, this layer will not process mouse events
    open func wantsMouseEvents() -> MouseEventTypeSet {
        return []
    }
    
    // This function is invoked immediately prior to setting up entities
    open func preSetup(canvas:Canvas) {
    }
    
    // This function is invoked immediately after setting up entities
    open func postSetup(canvas:Canvas) {
    }

    // This function is invoked immediately prior to calculating entities
    open func preCalculate(canvas:Canvas) {
    }
    
    // This function is invoked immediately after calculating entities
    open func postCalculate(canvas:Canvas) {
    }

    // This function is invoked immediately prior to rendering entities
    open func preRender(canvas:Canvas) {
    }

    // This function is invoked immediately after render entities
    open func postRender(canvas:Canvas) {
    }

}

extension Layer : Equatable {
    public static func == (lhs:Layer, rhs: Layer) -> Bool {
        return lhs === rhs
    }
}
