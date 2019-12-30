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
    private var backToFrontList : ZOrderedList<Layer>

    public private(set) weak var owner : DirectorBase?
    

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    public init() {
        wasSetup = false
        neverCalculated = true
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

