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

import Foundation
import Igis

open class Director : PainterProtocol, CustomStringConvertible {
    private let uniqueName : UniqueName
    private var sceneQueue : [Scene]
    private var shouldTransitionToNextScene : Bool
    private var currentScene : Scene?
    public lazy var dispatcher = Dispatcher(director:self)

    // ********************************************************************************
    // Functions for internal use
    // ********************************************************************************
    public required init() {
        uniqueName = UniqueName(objectType:Self.self, name:"Director")
        sceneQueue = [Scene]()
        shouldTransitionToNextScene = false
        currentScene = nil
    }

    public var name : String {
        return uniqueName.fullname
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
        
        dispatcher.raiseFrameUpdateEvent(framesPerSecond: framesPerSecond())
        
        scene.internalCalculate(canvas:canvas, director:self)
        scene.internalRender(canvas:canvas, director:self)
    }

    internal func internalRender(canvas:Canvas) {
        // Terminate the current scene if so indicated
        if currentScene != nil && shouldSceneTerminate() {
            currentScene!.internalTeardown()
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
    
    // This function is invoked whenever a browser first connects and after shouldSceneTerminate() returns true.
    internal func nextScene() -> Scene? {
        return sceneQueue.isEmpty ? nil : sceneQueue.removeFirst()
    }

    // This funcion is invoked after a scene completes a rendering cycle.
    internal func shouldSceneTerminate() -> Bool {
        let shouldTerminate = shouldTransitionToNextScene
        if shouldTransitionToNextScene {
            shouldTransitionToNextScene = false 
        }
        return shouldTerminate
    }

    // Provide an ordered list back-to-front of all objects in the current scene
    // Returns nil if no scene is current
    // Iff ignoreIsMouseTransparent will exclude any layers or entites
    // which are transparent
    internal func backToFrontList(ignoreIsMouseTransparent:Bool) -> Array<RenderableEntity>? {
        var entityList : Array<RenderableEntity>? = nil
        if let currentScene = currentScene {
            entityList = Array<RenderableEntity>()
            for layer in currentScene.backToFrontLayerList.list {
                if !ignoreIsMouseTransparent || !layer.isMouseTransparent() {
                    let layerEntities = layer.backToFrontEntityList.list
                    for entity in layerEntities {
                        if !ignoreIsMouseTransparent || !entity.isMouseTransparent() {
                            entityList!.append(entity)
                        }
                    }
                }
            }
        } 
        return entityList
    }

    // Provides an ordered list front-to-back of all objects in teh current scene
    // Returns nil if no scene is current
    // Iff ignoreIsMouseTransparent will exclude any layers or entities
    // which are transparent
    internal func frontToBackList(ignoreIsMouseTransparent:Bool) -> Array<RenderableEntity>? {
        var frontToBackList : Array<RenderableEntity>? = nil
        if let backToFrontList = backToFrontList(ignoreIsMouseTransparent:ignoreIsMouseTransparent) {
            frontToBackList = backToFrontList.reversed()
        }
        return frontToBackList
    }

    internal func frontMostEntity(atGlobalLocation globalLocation:Point, ignoreIsMouseTransparent:Bool = true) -> RenderableEntity? {
        var entity : RenderableEntity? = nil
        if let entityList = frontToBackList(ignoreIsMouseTransparent:ignoreIsMouseTransparent) {
            entity = entityList.first(where: {$0.hitTest(globalLocation:globalLocation)})
        } 
        return entity
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
        dispatcher.raiseMouseDownEvent(globalLocation:location)
    }
    
    public func onMouseUp(location:Point) {
        dispatcher.raiseMouseUpEvent(globalLocation:location)
    }
    
    public func onWindowMouseUp(location:Point) {
        // This handles the cancellation of any pending click, because the mouseUp event
        // occurred outside of the canvas
        dispatcher.raiseWindowMouseUpEvent(globalLocation:location)
    }
    
    public func onMouseMove(location:Point) {
        dispatcher.raiseMouseMoveEvent(globalLocation:location)
    }

    public func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        dispatcher.raiseKeyDownEvent(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
    }

    public func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        dispatcher.raiseKeyUpEvent(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
    }

    public func onCanvasResize(size:Size) {
        dispatcher.raiseCanvasResizeEvent(size:size)
    }
    
    public func onWindowResize(size:Size) {
        dispatcher.raiseWindowResizeEvent(size:size)
    }
    
    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public func enqueueScene(scene:Scene) {
        sceneQueue.append(scene)
    }

    public func transitionToNextScene() {
        shouldTransitionToNextScene = true
    }
    
    public var description : String {
        return name
    }
        
}

