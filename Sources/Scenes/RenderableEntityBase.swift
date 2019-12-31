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
  
open class RenderableEntityBase {

    internal private(set) var wasSetup : Bool
    internal private(set) var neverCalculated : Bool
    
    public private(set) weak var owner : Layer?

    public init() {
        wasSetup = false
        neverCalculated = true
        
        owner = nil
    }

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    internal func internalSetup(canvas:Canvas, layer:Layer) {
        precondition(!wasSetup, "Request to setup entity after already being setup")
        precondition(neverCalculated, "Request to setup entity after already being setup")
        precondition(owner == nil, "Request to setup entity but owner is not nil")
        
        owner = layer
        setup(canvas:canvas)
        wasSetup = true
    }

    internal func internalCalculate(canvas:Canvas, layer:Layer) {
        // In the event that this entity was added after the initial setup, it will not have been setup
        // We therefore check again now
        if !wasSetup {
            internalSetup(canvas:canvas, layer:layer)
        }

        precondition(wasSetup, "Request to calculate entity prior to setup")
        precondition(owner != nil, "Request to calculate entity but owner is nil")
        precondition(canvas.canvasSize != nil, "Request to calculate entity but canvas.canvasSize is nil")

        calculate(canvasSize:canvas.canvasSize!)

        neverCalculated = false
    }

    internal func internalRender(canvas:Canvas, layer:Layer) {
        // In the event that this entity was added after the initial setup, it will not have been calculated yet (or setup)
        // We therefore check again now
        if neverCalculated {
            internalCalculate(canvas:canvas, layer:layer)
        }

        precondition(wasSetup, "Request to render entity prior to setup")
        precondition(owner != nil, "Request to render entity but owner is nil")
        precondition(!neverCalculated, "Request to render entity but never calculated")
        
        precondition(canvas.canvasSize != nil, "Request to render entity but canvas.canvasSize is nil")

        render(canvas:canvas)
    }

    internal func internalOnMouseDown(location:Point) {
        precondition(wasSetup, "Request to process onMouseDown prior to setup")
        precondition(owner != nil, "Request to process onMouseDown but owner is nil")

        onMouseDown(location:location)
    }

    internal func internalOnMouseClick(location:Point) {
        precondition(wasSetup, "Request to process onMouseClick prior to setup")
        precondition(owner != nil, "Request to process onMouseClick but owner is nil")

        onMouseClick(location:location)
    }
    
    internal func internalOnMouseUp(location:Point) {
        precondition(wasSetup, "Request to process onMouseUp prior to setup")
        precondition(owner != nil, "Request to process onMouseUp but owner is nil")

        onMouseUp(location:location)
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************


    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    // This function is invoked when mouse actions occur
    // Unless the function is overridden to return the desired mouseEvents, this entity will not process mouse events
    open func wantsMouseEvents() -> MouseEventTypeSet {
        return []
    }

    // setup() is invoked exactly once,
    // either when the owning layer is first set up or,
    // if the layer has already been setup,
    // prior to the next calculate event
    open func setup(canvas:Canvas) {
    }
    
    // calculate() is invoked prior to each render event
    open func calculate(canvasSize:Size) {
    }
    
    // render() is invoked during each render cycle
    open func render(canvas:Canvas) {
    }

    open func boundingRect() -> Rect {
        return Rect(topLeft:Point(x:0, y:0), size:Size(width:0, height:0))
    }
    
    open func hitTest(location:Point) -> Bool  {
        return boundingRect().containment(target:location).contains(.containedFully)
    }

    open func onMouseDown(location:Point) {
    }
    
    open func onMouseUp(location:Point) {
    }
    
    open func onMouseClick(location:Point) {
    }

    open func onMouseEnter(location:Point) {
    }
    
    open func onMouseLeave(location:Point) {
    }
      
}

extension RenderableEntityBase : Equatable {
    public static func == (lhs:RenderableEntityBase, rhs:RenderableEntityBase) -> Bool {
        return lhs === rhs
    }
}
