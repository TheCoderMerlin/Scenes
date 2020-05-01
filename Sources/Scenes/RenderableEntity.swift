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
  
open class RenderableEntity {
    private let uniqueName : UniqueName
    internal private(set) var wasSetup : Bool
    internal private(set) var wasTorndown : Bool
    internal private(set) var neverCalculated : Bool
    private var transforms : [Transform]?
    private var alpha : Alpha?
    private var clipPath : ClipPath?
    
    public private(set) weak var owningLayer : Layer?

    public init(name:String?=nil) {
        uniqueName = UniqueName(objectType:Self.self, name:name)
        wasSetup = false
        wasTorndown = false
        neverCalculated = true

        owningLayer = nil
    }

    public var name : String {
        return uniqueName.fullname
    }

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    internal func internalSetup(canvas:Canvas, layer:Layer) {
        precondition(!wasSetup, "Request to setup entity after already being setup")
        precondition(neverCalculated, "Request to setup entity after already being setup")
        precondition(owningLayer == nil, "Request to setup entity but owningLayer is not nil")
        precondition(canvas.canvasSize != nil, "Request to setup entity but canvas.canvasSize is nil")
        
        owningLayer = layer
        setup(canvasSize:canvas.canvasSize!, canvas:canvas)
        wasSetup = true
    }

    internal func internalTeardown() {
        precondition(wasSetup, "Request to teardown entity that was not yet setup")
        precondition(!wasTorndown, "Request to teardown entity that was already torn down")

        teardown()
        wasTorndown = true
    }

    internal func internalCalculate(canvas:Canvas, layer:Layer) {
        // In the event that this entity was added after the initial setup, it will not have been setup
        // We therefore check again now
        if !wasSetup {
            internalSetup(canvas:canvas, layer:layer)
        }

        precondition(wasSetup, "Request to calculate entity prior to setup")
        precondition(owningLayer != nil, "Request to calculate entity but owningLayer is nil")
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
        precondition(owningLayer != nil, "Request to render entity but owningLayer is nil")
        precondition(!neverCalculated, "Request to render entity but never calculated")
        precondition(canvas.canvasSize != nil, "Request to render entity but canvas.canvasSize is nil")

        // Apply transforms, alpha, and clipPath if specified
        let restoreStateRequired = (transforms != nil || alpha != nil || clipPath != nil)
        if restoreStateRequired {
            let state = State(mode:.save)
            canvas.render(state)

            if let transforms = transforms {
                canvas.render(transforms)
            }

            if let alpha = alpha {
                canvas.render(alpha)
            }

            if let clipPath = clipPath {
                canvas.render(clipPath)
            }
        }
        
        // Render entity
        render(canvas:canvas)

        // Restore state if required
        if restoreStateRequired {
            let state = State(mode:.restore)
            canvas.render(state)
        }
    }


    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public func local(fromGlobal:Point) -> Point {
        let topLeft = boundingRect().topLeft
        return Point(x:fromGlobal.x - topLeft.x, y:fromGlobal.y - topLeft.y)
    }

    public func global(fromLocal:Point) -> Point {
        let topLeft = boundingRect().topLeft
        return Point(x:fromLocal.x + topLeft.x, y:fromLocal.y + topLeft.y)
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func setTransforms(transforms:[Transform]?) {
        self.transforms = transforms
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func setAlpha(alpha:Alpha?) {
        self.alpha = alpha
    }

    // This function should only be invoked during init(), setup(), or calculate()
    public func setClipPath(clipPath:ClipPath?) {
        self.clipPath = clipPath
    }

    // Applies specified or current transforms to the specified point
    // If no transforms are current, returns the original point
    public func applyTransforms(toPoint:Point, transforms:[Transform]? = nil) -> Point {
        if let transforms = transforms ?? self.transforms {
            let matrix = Transform.multiply(transforms:transforms)
            let transformedPoint = matrix.apply(toPoint:toPoint)
            return transformedPoint
        } else {
            return toPoint
        }
    }

    // Applies specified or current transforms to the specified points
    // If no transforms are current, returns the original points
    public func applyTransforms(toPoints:[Point], transforms:[Transform]? = nil) -> [Point] {
        if let transforms = transforms ?? self.transforms {
            let matrix = Transform.multiply(transforms:transforms)
            let transformedPoints = matrix.apply(toPoints:toPoints)
            return transformedPoints
        } else {
            return toPoints
        }
    }

    public var layer : Layer {
        guard let owningLayer = owningLayer else {
            fatalError("owningLayer required")
        }
        return owningLayer
    }

    public var scene : Scene {
        return layer.scene
    }
    
    public var director : Director {
        return scene.director
    }

    public var dispatcher : Dispatcher {
        return director.dispatcher
    }

    public var animationManager : AnimationManager {
        return director.animationManager
    }

    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************

    // setup() is invoked exactly once,
    // either when the owning layer is first set up or,
    // if the layer has already been setup,
    // prior to the next calculate event
    // This is the appropriate location to register event handlers
    open func setup(canvasSize:Size, canvas:Canvas) {
    }

    // teardown() is invoked exactly once
    // when the scene is torndown prior to a
    // transition
    // This is the appropriate location to unregister event handlers
    open func teardown() {
    }
    
    // calculate() is invoked prior to each render event
    open func calculate(canvasSize:Size) {
    }
    
    // render() is invoked during each render cycle
    open func render(canvas:Canvas) {
    }

    // Must be over-ridden to return the boundingRect of the entity, in global coordinates
    open func boundingRect() -> Rect {
        return Rect(topLeft:Point(x:0, y:0), size:Size(width:0, height:0))
    }
    
    // Must be over-ridden to return true iff the location generates a hit
    open func hitTest(globalLocation:Point) -> Bool  {
        return boundingRect().containment(target:globalLocation).contains(.containedFully)
    }

    // This function is invoked to determine whether or not an entity is transparent
    // to entity mouse events
    // If true, the entity will not intercept such events
    open func isMouseTransparent() -> Bool {
        return false
    }
}

extension RenderableEntity : Equatable {
    public static func == (lhs:RenderableEntity, rhs:RenderableEntity) -> Bool {
        return lhs === rhs
    }
}
