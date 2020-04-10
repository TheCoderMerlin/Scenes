/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2019,2020 Tango Golf Digital, LLC
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
    private let uniqueName : UniqueName
    internal private(set) var wasSetup : Bool
    internal private(set) var wasTorndown : Bool
    internal private(set) var neverCalculated : Bool
    internal private(set) weak var mostRecentMouseDownEntity : RenderableEntity?
    private var backToFrontList : ZOrderedList<RenderableEntity>
    private var transforms : [Transform]?
    private var alpha : Alpha?

    public private(set) weak var owningScene : Scene?

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    
    public init(name:String?=nil) {
        uniqueName = UniqueName(objectType:Self.self, name:name)
        wasSetup = false
        wasTorndown = false
        neverCalculated = true
        mostRecentMouseDownEntity = nil
        backToFrontList = ZOrderedList<RenderableEntity>()

        owningScene = nil
    }

    public var name : String {
        return uniqueName.fullname
    }

    internal func internalSetup(canvas:Canvas, scene:Scene) {
        precondition(!wasSetup, "Request to setup layer after already being setup")
        precondition(neverCalculated, "Request to setup layer after already being calculated")
        precondition(owningScene == nil, "Request to setup layer but owningScene is not nil")
        precondition(canvas.canvasSize != nil, "Request to setup layer but canvas.canvasSize is nil")
        
        owningScene = scene

        // Setup all entities
        preSetup(canvasSize:canvas.canvasSize!, canvas:canvas)
        for entity in backToFrontList.list {
            if !entity.wasSetup {
                entity.internalSetup(canvas:canvas, layer:self)
            }
        }
        postSetup(canvasSize:canvas.canvasSize!, canvas:canvas)

        wasSetup = true
    }

    internal func internalTeardown() {
        precondition(wasSetup, "Request to teardown layer that was not yet setup")
        precondition(!wasTorndown, "Request to teardown layer that was already torn down")

        preTeardown()
        for entity in backToFrontList.list {
            if entity.wasSetup && !entity.wasTorndown {
                entity.internalTeardown()
            }
        }
        postTeardown()

        wasTorndown = true
    }

    internal func internalCalculate(canvas:Canvas, scene:Scene) {
        // Layers added after the initial setup may not yet have been setup
        // We therefore check again now
        if !wasSetup {
            internalSetup(canvas:canvas, scene:scene)
        }

        precondition(wasSetup, "Request to calculate layer prior to setup")
        precondition(owningScene != nil, "Request to calculate layer but owningScene is nil")

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
        precondition(owningScene != nil, "Request to render layer but owningScene is nil")
        precondition(!neverCalculated, "Request to render layer but never calculated")

        // Apply alpha and transforms if specified
        let restoreStateRequired = (transforms != nil || alpha != nil)
        if restoreStateRequired {
            let state = State(mode:.save)
            canvas.render(state)

            if let transforms = transforms {
                canvas.render(transforms)
            }

            if let alpha = alpha {
                canvas.render(alpha)
            }
        }
        
        // Render all entities
        preRender(canvas:canvas)
        for entity in backToFrontList.list {
            entity.internalRender(canvas:canvas, layer:self)
        }
        postRender(canvas:canvas)

        // Restore state if required
        if restoreStateRequired {
            let state = State(mode:.restore)
            canvas.render(state)
        }
    }

    internal var backToFrontEntityList : ZOrderedList<RenderableEntity> {
        return backToFrontList
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    // This function should only be invoked during init(), setup(), or calculate()
    public func insert(entity:RenderableEntity, at zLocation:ZOrder<RenderableEntity>) {
        backToFrontList.insert(object:entity, at:zLocation)
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func moveZ(of entity:RenderableEntity, to zLocation:ZOrder<RenderableEntity>) {
        backToFrontList.moveZ(of:entity, to:zLocation)
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) {
        self.transforms = transforms
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) {
        self.alpha = alpha
    }

    public var scene : Scene {
        guard let owningScene = owningScene else {
            fatalError("owningScene required")
        }
        return owningScene
    }
    
    public var director : Director {
        return scene.director
    }

    public var dispatcher : Dispatcher {
        return director.dispatcher
    }
    
    // ********************************************************************************
    // DEBUG API FOLLOWS
    // ********************************************************************************
    
    // Prints list of entities from back to front
    public func debugEntityList() {
        print("==================== \(name) debugEntityList")
        for entity in backToFrontList.list {
            print("\t\(entity.name)")
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    
    // This function is invoked immediately prior to setting up entities
    open func preSetup(canvasSize:Size, canvas:Canvas) {
    }
    
    // This function is invoked immediately after setting up entities
    open func postSetup(canvasSize:Size, canvas:Canvas) {
    }

    // This function is invoked immediately prior to tearing down layers
    open func preTeardown() {
    }

    // This function is invoked immediately after tearing down layers
    open func postTeardown() {
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

    // This function is invoked to determine whether or not a layer is transparent
    // to entity mouse events
    // If true, the layer's entities will not intercept such events
    open func isMouseTransparent() -> Bool {
        return false
    }
}

extension Layer : Equatable {
    public static func == (lhs:Layer, rhs: Layer) -> Bool {
        return lhs === rhs
    }
}
