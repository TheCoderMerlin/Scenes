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

/// A `Scene` is responsible for providing the required `Layer`s for an
/// application.
open class Scene : IdentifiableObject {
    internal private(set) var wasSetup : Bool
    internal private(set) var wasTorndown : Bool
    internal private(set) var neverCalculated : Bool
    internal private(set) weak var mostRecentMouseDownLayer : Layer?
    private var backToFrontList : ZOrderedList<Layer>

    public private(set) weak var owningDirector : Director?

    /// Creates a new `Scene` from the given parameters:
    /// - Parameters:
    ///   - name: The unique name of this scene. While it's very useful
    ///           for debugging purposes to provide a meaningful name,
    ///           it's not required.
    public override init(name:String?=nil) {
        wasSetup = false
        wasTorndown = false
        neverCalculated = true
        mostRecentMouseDownLayer = nil
        backToFrontList = ZOrderedList<Layer>()

        owningDirector = nil

        super.init(name:name)
    }

    // ****************************************************************
    // Functions for internal use
    // ****************************************************************

    internal func internalSetup(canvas:Canvas, director:Director) {
        precondition(!wasSetup, "Request to setup scene after already being setup")
        precondition(neverCalculated, "Request to setup scene after already being calculated")
        precondition(owningDirector == nil, "Request to setup scene but owningDirector is not nil")
        precondition(canvas.canvasSize != nil, "Request to setup scene but canvas.canvasSize is nil")
        
        owningDirector = director

        // Setup all layers
        preSetup(canvasSize:canvas.canvasSize!, canvas:canvas)
        for layer in backToFrontList.list {
            if !layer.wasSetup {
                layer.internalSetup(canvas:canvas, scene:self)
            }
        }
        postSetup(canvasSize:canvas.canvasSize!, canvas:canvas)
        
        wasSetup = true
    }

    internal func internalTeardown() {
        precondition(wasSetup, "Request to teardown scene that was not yet setup")
        precondition(!wasTorndown, "Request to teardown scene that was already torn down")

        preTeardown()
        for layer in backToFrontList.list {
            if layer.wasSetup && !layer.wasTorndown {
                layer.internalTeardown()
            }
        }
        postTeardown()

        dispatcher.debugListRegisteredHandlers()

        wasTorndown = true
    }

    internal func internalCalculate(canvas:Canvas, director:Director) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to calculate scene prior to setup")
        precondition(owningDirector != nil, "Request to calculate scene but owningDirector is nil")

        // Calculate all layers
        preCalculate(canvas:canvas)
        for layer in backToFrontList.list {
            layer.internalCalculate(canvas:canvas, scene:self)
        }
        postCalculate(canvas:canvas)

        neverCalculated = false
    }

    internal func internalRender(canvas:Canvas, director:Director) {
        // At this point, we must have already been set up
        precondition(wasSetup, "Request to render scene prior to setup")
        precondition(owningDirector != nil, "Request to render scene but owningDirector is nil")

        // At this point, we must have already calculated
        precondition(!neverCalculated, "Request to render scene but never calculated")

        // Render all layers
        preRender(canvas:canvas)
        for layer in backToFrontList.list {
            layer.internalRender(canvas:canvas, scene:self)
        }
        postRender(canvas:canvas)
    }

    internal var backToFrontLayerList : ZOrderedList<Layer> {
        return backToFrontList
    }
    
    // ****************************************************************
    // API FOLLOWS
    // ****************************************************************

    /// Inserts the specified layer at the specified location.
    /// This function should only be invoked during init(), setup(), or calculate().
    public func insert(layer:Layer, at zLocation:ZOrder<Layer>) {
        backToFrontList.insert(object:layer, at:zLocation)
    }

    /// Removes the specified layer from this scene.
    /// This function should only be invoked during init(), setup(), or calculate().
    public func remove(layer: Layer) {
        backToFrontList.remove(object: layer)
    }

    /// Moves the z-index value of the specified layer according to the
    /// specified location.
    /// This function should only be invoked during init(), setup(), or calculate().
    public func moveZ(of layer:Layer, to zLocation:ZOrder<Layer>) {
        backToFrontList.moveZ(of:layer, to:zLocation)
    }

    /// The owning director for this scene.
    public var director : Director {
        guard let owningDirector = owningDirector else {
            fatalError("owningDirector required")
        }
        return owningDirector
    }

    /// The event dispatcher for this scenes owning director.
    public var dispatcher : Dispatcher {
        return director.dispatcher
    }

    // ****************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ****************************************************************

    /// This function is invoked immediately prior to setting up layers.
    open func preSetup(canvasSize:Size, canvas:Canvas) {
    }
    
    /// This function is invoked immediately after setting up layers.
    open func postSetup(canvasSize:Size, canvas:Canvas) {
    }

    /// This function is invoked immediately prior to tearing down layers.
    open func preTeardown() {
    }

    /// This function is invoked immediately after tearing down layers.
    open func postTeardown() {
    }

    /// This function is invoked immediately prior to calculating layers.
    open func preCalculate(canvas:Canvas) {
    }
    
    /// This function is invoked immediately after calculating layers.
    open func postCalculate(canvas:Canvas) {
    }

    /// This function is invoked immediately prior to rendering layers.
    open func preRender(canvas:Canvas) {
    }
    
    /// This function is invoked immediately after rendering layers.
    open func postRender(canvas:Canvas) {
    }
}
