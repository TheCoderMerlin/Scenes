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

open class Director : PainterProtocol {
    private var currentScene : Scene? 

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    public required init() {
        currentScene = nil
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
        // Obtain a new scene, if available
        if currentScene == nil {
            currentScene = nextScene()
        }

        // At this point, if we don't have a currentScene, we're done and exit,
        // otherwise, process the render for the scene
        if let currentScene = currentScene {
            internalRender(canvas:canvas, scene:currentScene)
        } else {
            exit(0)
        }
    }
    
    public func render(canvas:Canvas) {
        // Do nothing until we have a canvasSize
        if canvas.canvasSize != nil {
            internalRender(canvas:canvas)
        }
    }

    public func onCanvasResize(size:Size) {
    }
    
    public func onWindowResize(size:Size) {
    }
    
    public func onClick(location:Point) {
    }
    
    public func onMouseDown(location:Point) {
    }
    
    public func onMouseUp(location:Point) {
    }
    
    public func onMouseMove(location:Point) {
    }

    public func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
    }


    // ********************************************************************************
    // API FOLLOWS
    // These functions should be over-ridden by descendant classes
    // ********************************************************************************
    open func nextScene() -> Scene? {
        return nil
    }
    
}

