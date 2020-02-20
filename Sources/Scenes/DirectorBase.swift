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

import Foundation
import Igis

open class DirectorBase : PainterProtocol {
    private var currentScene : Scene?
    private var previousMouseLocation : Point?

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    public required init() {
        currentScene = nil
        previousMouseLocation = nil
    }

    open func framesPerSecond() -> Int {
        return 10
    }
    
    public func setup(canvas:Canvas) {
        // We ignore setup(), and handle all logic in render
    }
    
    public func calculate(canvasId:Int, canvasSize:Size?) {
        // We ignore calculate, and handle all logic in render
    }

    internal func internalRender(canvas:Canvas, scene:Scene) {
        // Set up the scene if required
        if !scene.wasSetup {
            scene.internalSetup(canvas:canvas, director:self)
        }

        scene.internalCalculate(canvas:canvas, director:self)
        scene.internalRender(canvas:canvas, director:self)
    }

    internal func internalRender(canvas:Canvas) {
        // Terminate the current scene if so indicated
        if currentScene != nil && shouldSceneTerminate() {
            currentScene = nil
        }
        
        // Obtain a new scene, if available
        if currentScene == nil {
            currentScene = nextScene()
        }

        // If we have a scene at this point, begin rendering
        if let currentScene = currentScene {
            internalRender(canvas:canvas, scene:currentScene)
        }
    }
    
    public func render(canvas:Canvas) {
        // Do nothing until we have a canvasSize
        if canvas.canvasSize != nil {
            internalRender(canvas:canvas)
        }
    }

    public func onClick(location:Point) {
        // We ignore clicks, and handle onMouseDown, onMouseUp, and onMouseMove
    }
    
    public func onMouseDown(location:Point) {
        if let currentScene = currentScene,
           currentScene.wasSetup {
            let desiredMouseEvents = currentScene.wantsMouseEvents()
            let shouldInvoke = !desiredMouseEvents.intersection([.downUp, .click, .drag]).isEmpty
            if shouldInvoke {
                currentScene.internalOnMouseDown(globalLocation:location)
            }
        }
    }
    
    public func onMouseUp(location:Point) {
        if let currentScene = currentScene,
           currentScene.wasSetup {
            let desiredMouseEvents = currentScene.wantsMouseEvents()
            let shouldInvoke = !desiredMouseEvents.intersection([.downUp, .click, .drag]).isEmpty
            if shouldInvoke {
                currentScene.internalOnMouseUp(globalLocation:location)
            }
        }
    }
    
    public func onWindowMouseUp(location:Point) {
        // This handles the cancellation of any pending click, because the mouseUp event
        // occurred outside of the canvas
        
        if let currentScene = currentScene,
           currentScene.wasSetup {
            let desiredMouseEvents = currentScene.wantsMouseEvents()
            let shouldInvoke = !desiredMouseEvents.intersection([.downUp, .click, .drag]).isEmpty
            if shouldInvoke {
                currentScene.internalCancelPendingMouseClick()
            }
        }
    }
    
    public func onMouseMove(location:Point) {
        if let previousMouseLocation = previousMouseLocation,
           let currentScene = currentScene,
           currentScene.wasSetup {
            let movement = Point(x:location.x - previousMouseLocation.x, y:location.y - previousMouseLocation.y)
            // Oddly, moveMove is frequently invoked without any movement
            /// There's no point in executing the event handler if this is the case
            if (movement.x != 0 || movement.y != 0) {
                let desiredMouseEvents = currentScene.wantsMouseEvents()
                let shouldInvoke = !desiredMouseEvents.intersection([.move, .drag]).isEmpty
                if shouldInvoke {
                    currentScene.internalOnMouseMove(globalLocation:location, movement:movement)
                }
            }
        }
        previousMouseLocation = location
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    
    
    // ********************************************************************************
    // API FOLLOWS
    // These functions MAY be over-ridden by descendant classes
    // ********************************************************************************

    // This function should be overridden to provide the next scene object to be rendered.
    // It is invoked whenever a browser first connects and after shouldSceneTerminate() returns true.
    open func nextScene() -> Scene? {
        return nil
    }

    // This function should be overridden for multi-scene presentations.
    // It is invoked after a scene completes a rendering cycle.
    open func shouldSceneTerminate() -> Bool {
        return false
    }

    open func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
    }

    open func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
    }

    open func onCanvasResize(size:Size) {
    }
    
    open func onWindowResize(size:Size) {
    }
    
    
}

