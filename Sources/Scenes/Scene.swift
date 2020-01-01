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

open class Scene {

    internal private(set) var wasSetup : Bool
    internal private(set) var neverCalculated : Bool
    internal private(set) weak var mostRecentMouseDownLayer : Layer?
    private var backToFrontList : ZOrderedList<Layer>

    public private(set) weak var owner : DirectorBase?
    

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    public init() {
        wasSetup = false
        neverCalculated = true
        mostRecentMouseDownLayer = nil
        backToFrontList = ZOrderedList<Layer>()

        owner = nil
    }

    internal func internalSetup(canvas:Canvas, director:DirectorBase) {
        precondition(!wasSetup, "Request to setup scene after already being setup")
        precondition(neverCalculated, "Request to setup scene after already being calculated")
        precondition(owner == nil, "Request to setup scene but owner is not nil")
        
        owner = director

        // Setup all layers
        preSetup(canvas:canvas)
        for layer in backToFrontList.list {
            if !layer.wasSetup {
                layer.internalSetup(canvas:canvas, scene:self)
            }
        }
        postSetup(canvas:canvas)
        
        wasSetup = true
    }

    internal func internalCalculate(canvas:Canvas, director:DirectorBase) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to calculate scene prior to setup")
        precondition(owner != nil, "Request to calculate scene but owner is nil")

        // Calculate all layers
        preCalculate(canvas:canvas)
        for layer in backToFrontList.list {
            layer.internalCalculate(canvas:canvas, scene:self)
        }
        postCalculate(canvas:canvas)

        neverCalculated = false
    }

    internal func internalRender(canvas:Canvas, director:DirectorBase) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to render scene prior to setup")
        precondition(owner != nil, "Request to render scene but owner is nil")

        // At this point, we must have already calculated
        precondition(!neverCalculated, "Request to render scene but never calculated")

        // Render all layers
        preRender(canvas:canvas)
        for layer in backToFrontList.list {
            layer.internalRender(canvas:canvas, scene:self)
        }
        postRender(canvas:canvas)
    }

    internal func internalOnMouseDown(globalLocation:Point) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseDown prior to setup")
        precondition(owner != nil, "Request to process onMouseDown but owner is nil")

        // Also, there must not be a mostRecentMouseDownEntity
        precondition(mostRecentMouseDownLayer == nil, "Request to process onMouseDown but mostRecentMouseDownLayer is not nil")

        let frontToBackList = backToFrontList.list.reversed()
        for layer in frontToBackList {
            if layer.wasSetup {
                let desiredMouseEvents = layer.wantsMouseEvents()
                let shouldInvoke = !desiredMouseEvents.intersection([.downUp, .click, .drag]).isEmpty
                if shouldInvoke {
                    mostRecentMouseDownLayer = layer.internalOnMouseDown(globalLocation:globalLocation)
                    if (mostRecentMouseDownLayer != nil) {
                        return
                    }
                }
            }
        }
    }

    internal func internalOnMouseUp(globalLocation:Point) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseDown prior to setup")
        precondition(owner != nil, "Request to process onMouseDown but owner is nil")

        // If we have a mostRecentMouseDownLayer, we process the potential click first
        // We need to process this internal event even if the object itself does not want the click,
        // in order to clear the mouse down event
        if let mostRecentMouseDownLayer = mostRecentMouseDownLayer {
            mostRecentMouseDownLayer.internalOnMouseClick(globalLocation:globalLocation)
        }

        // Terminate the moseRecentMouseDownLayer
        mostRecentMouseDownLayer = nil
        
        // Now search for whatever object may have a mouseUp event (it may be the same object as the click)
        let frontToBackList = backToFrontList.list.reversed()
        for layer in frontToBackList {
            if layer.wasSetup {
                let desiredMouseEvents = layer.wantsMouseEvents()
                if desiredMouseEvents.contains(.downUp) {
                    layer.internalOnMouseUp(globalLocation:globalLocation)
                    return
                }
            }
        }
    }

    internal func internalCancelPendingMouseClick() {
        // This handles the cancellation of any pending click, because the mouseUp event
        // occurred outside of the canvas
        
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseDown prior to setup")
        precondition(owner != nil, "Request to process onMouseDown but owner is nil")

        // If we have a mostRecentMouseDownLayer, we process the cancellation
        // We need to process this internal event even if the object itself does not want the click,
        // in order to clear the mouse down event
        if let mostRecentMouseDownLayer = mostRecentMouseDownLayer {
            mostRecentMouseDownLayer.internalCancelPendingMouseClick()
        }

        // Terminate the mostRecentMouseDownLayer
        mostRecentMouseDownLayer = nil
    }
    
    internal func internalOnMouseMove(globalLocation:Point, movement:Point) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to process onMouseMove prior to setup")
        precondition(owner != nil, "Request to process onMouseMove but owner is nil")

        // Handle movement by notifying all interested entities
        let frontToBackList = backToFrontList.list.reversed()
        for layer in frontToBackList {
            if layer.wasSetup {
                let desiredMouseEvents = layer.wantsMouseEvents()
                if desiredMouseEvents.contains(.move) {
                    layer.internalOnMouseMove(globalLocation:globalLocation, movement:movement)
                }
            }
        }

        // Handle a drag if requested
        if let mostRecentMouseDownLayer = mostRecentMouseDownLayer,
           mostRecentMouseDownLayer.wantsMouseEvents().contains(.drag) {
            mostRecentMouseDownLayer.internalOnMouseDrag(globalLocation:globalLocation, movement:movement)
        }
    }
    
    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************
    public func insert(layer:Layer, at zLocation:ZOrder<Layer>) {
        backToFrontList.insert(object:layer, at:zLocation)
    }

    public func moveZ(of layer:Layer, to zLocation:ZOrder<Layer>) {
        backToFrontList.moveZ(of:layer, to:zLocation)
    }
    
    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    // This function is invoked when mouse actions occur
    // Unless the function is overridden to return the desired mouseEvents, this scene will not process mouse events
    open func wantsMouseEvents() -> MouseEventTypeSet {
        return []
    }

    // This function is invoked immediately prior to setting up layers
    open func preSetup(canvas:Canvas) {
    }
    
    // This function is invoked immediately after setting up layers
    open func postSetup(canvas:Canvas) {
    }

    // This function is invoked immediately prior to calculating layers
    open func preCalculate(canvas:Canvas) {
    }
    
    // This function is invoked immediately after calculating layers
    open func postCalculate(canvas:Canvas) {
    }

    // This function is invoked immediately prior to rendering layers
    open func preRender(canvas:Canvas) {
    }
    
    // This function is invoked immediately after rendering layers
    open func postRender(canvas:Canvas) {
    }

}

