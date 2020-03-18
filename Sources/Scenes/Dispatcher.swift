/*
Scenes provides a Swift object library with support for renderable entities,
layers, and scenes.  Scenes runs on top of IGIS.
Copyright (C) 2020 Tango Golf Digital, LLC
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

public class Dispatcher {
    // Parent
    private weak var director : Director?
    
    // Key Handlers
    private var registeredKeyDownHandlers = [KeyDownHandler]()
    private var registeredKeyUpHandlers   = [KeyUpHandler]()

    // Resize Handlers
    private var registeredCanvasResizeHandlers = [CanvasResizeHandler]()
    private var registeredWindowResizeHandlers = [WindowResizeHandler]()

    // Mouse Handlers
    private var registeredMouseDownHandlers = [MouseDownHandler]()
    private var registeredMouseUpHandlers   = [MouseUpHandler]()
    private var registeredMouseMoveHandlers = [MouseMoveHandler]()

    // Entity Mouse Handlers
    private var registeredEntityMouseDownHandlers  = [EntityMouseDownHandler]()
    private var registeredEntityMouseUpHandlers    = [EntityMouseUpHandler]()
    private var registeredEntityMouseClickHandlers = [EntityMouseClickHandler]()
    private var registeredEntityMouseDragHandlers = [EntityMouseDragHandler]()
    private var mostRecentEntityMouseDownHandler : EntityMouseDownHandler? = nil

    // Mouse State
    private var previousMouseLocation : Point? = nil

    init(director:Director) {
        self.director = director
    }

    // ========== Debug APIs ==========
    public func debugListRegisteredHandlers() {
        debugListRegisteredHandlers(handlers:registeredKeyDownHandlers, name:"keyDown")
        debugListRegisteredHandlers(handlers:registeredKeyUpHandlers, name:"keyUp")

        debugListRegisteredHandlers(handlers:registeredCanvasResizeHandlers, name:"canvasResize")
        debugListRegisteredHandlers(handlers:registeredWindowResizeHandlers, name:"windowResize")
        
        debugListRegisteredHandlers(handlers:registeredMouseDownHandlers, name:"mouseDown")
        debugListRegisteredHandlers(handlers:registeredMouseUpHandlers, name:"mouseUp")
        debugListRegisteredHandlers(handlers:registeredMouseMoveHandlers, name:"mouseMove")
        
        debugListRegisteredHandlers(handlers:registeredEntityMouseDownHandlers, name:"entityMouseDown")
        debugListRegisteredHandlers(handlers:registeredEntityMouseUpHandlers, name:"entityMouseUp")
        debugListRegisteredHandlers(handlers:registeredEntityMouseClickHandlers, name:"entityMouseClick")
        debugListRegisteredHandlers(handlers:registeredEntityMouseDragHandlers, name:"entityMouseDrag")
    }
    
    internal func debugListRegisteredHandlers(handlers:[EventHandler], name:String) {
        if !handlers.isEmpty {
            print("========== \(name) handlers")
            for handler in handlers {
                print("\t\(handler.name)")
            }
        }
    }

    // ========== KeyDownHandler ==========
    public func registerKeyDownHandler(handler:KeyDownHandler) {
        precondition(!registeredKeyDownHandlers.contains(where: {$0.name == handler.name}), "registerKeyDownHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredKeyDownHandlers.append(handler)
    }

    public func unregisterKeyDownHandler(handler:KeyDownHandler) {
        precondition(registeredKeyDownHandlers.contains(where: {$0.name == handler.name}), "unregisterKeyDownHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredKeyDownHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseKeyDownEvent(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        for handler in registeredKeyDownHandlers {
            handler.onKeyDown(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
        }
    }

    // ========== KeyUpHandler ==========
    public func registerKeyUpHandler(handler:KeyUpHandler) {
        precondition(!registeredKeyUpHandlers.contains(where: {$0.name == handler.name}), "registerKeyUpHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredKeyUpHandlers.append(handler)
    }

    public func unregisterKeyUpHandler(handler:KeyUpHandler) {
        precondition(registeredKeyUpHandlers.contains(where: {$0.name == handler.name}), "unregisterKeyUpHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredKeyUpHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseKeyUpEvent(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        for handler in registeredKeyUpHandlers {
            handler.onKeyUp(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)
        }
    }
    
    // ========== MouseDownHandler ==========
    public func registerMouseDownHandler(handler:MouseDownHandler) {
        precondition(!registeredMouseDownHandlers.contains(where: {$0.name == handler.name}), "registerMouseDownHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredMouseDownHandlers.append(handler)
    }

    public func unregisterMouseDownHandler(handler:MouseDownHandler) {
        precondition(registeredMouseDownHandlers.contains(where: {$0.name == handler.name}), "unregisterMouseDownHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredMouseDownHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseMouseDownEvent(globalLocation:Point) {
        for handler in registeredMouseDownHandlers {
            handler.onMouseDown(globalLocation:globalLocation)
        }

        // Raise the event for entities
        raiseEntityMouseDownEvent(globalLocation:globalLocation)
    }
    
    // ========== MouseUpHandler ==========
    public func registerMouseUpHandler(handler:MouseUpHandler) {
        precondition(!registeredMouseUpHandlers.contains(where: {$0.name == handler.name}), "registerMouseUpHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredMouseUpHandlers.append(handler)
    }

    public func unregisterMouseUpHandler(handler:MouseUpHandler) {
        precondition(registeredMouseUpHandlers.contains(where: {$0.name == handler.name}), "unregisterMouseUpHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredMouseUpHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseMouseUpEvent(globalLocation:Point) {
        for handler in registeredMouseUpHandlers {
            handler.onMouseUp(globalLocation:globalLocation)
        }

        // Raise the event for entities
        raiseEntityMouseUpEvent(globalLocation:globalLocation)

        // Clear the most recent entity mouseDown handler
        mostRecentEntityMouseDownHandler = nil
    }

    // ========== WindowMouseUpHandler ==========
    internal func raiseWindowMouseUpEvent(globalLocation:Point) {
        // This handles the cancellation of any pending click, because the mouseUp event
        // occurred outside of the canvas
        // The coordinates match that of the canvas, so we simply relay this event
        raiseMouseUpEvent(globalLocation:globalLocation)
    }
    
    // ========== CanvasResizeHandler ==========
    public func registerCanvasResizeHandler(handler:CanvasResizeHandler) {
        precondition(!registeredCanvasResizeHandlers.contains(where: {$0.name == handler.name}), "registerCanvasResizeHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredCanvasResizeHandlers.append(handler)
    }

    public func unregisterCanvasResizeHandler(handler:CanvasResizeHandler) {
        precondition(registeredCanvasResizeHandlers.contains(where: {$0.name == handler.name}), "unregisterCanvasResizeHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredCanvasResizeHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseCanvasResizeEvent(size:Size) {
        for handler in registeredCanvasResizeHandlers {
            handler.onCanvasResize(size:size)
        }
    }

    // ========== WindowResizeHandler ==========
    public func registerWindowResizeHandler(handler:WindowResizeHandler) {
        precondition(!registeredWindowResizeHandlers.contains(where: {$0.name == handler.name}), "registerWindowResizeHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredWindowResizeHandlers.append(handler)
    }

    public func unregisterWindowResizeHandler(handler:WindowResizeHandler) {
        precondition(registeredWindowResizeHandlers.contains(where: {$0.name == handler.name}), "unregisterWindowResizeHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredWindowResizeHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseWindowResizeEvent(size:Size) {
        for handler in registeredWindowResizeHandlers {
            handler.onWindowResize(size:size)
        }
    }

    // ========== MouseMoveHandler ==========
    public func registerMouseMoveHandler(handler:MouseMoveHandler) {
        precondition(!registeredMouseMoveHandlers.contains(where: {$0.name == handler.name}), "registerMouseMoveHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredMouseMoveHandlers.append(handler)
    }

    public func unregisterMouseMoveHandler(handler:MouseMoveHandler) {
        precondition(registeredMouseMoveHandlers.contains(where: {$0.name == handler.name}), "unregisterMouseMoveHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredMouseMoveHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseMouseMoveEvent(globalLocation:Point) {
        if let previousMouseLocation = previousMouseLocation {
            let movement = Point(x:globalLocation.x-previousMouseLocation.x,y:globalLocation.y-previousMouseLocation.y)
            // We sometimes receive this "Move" event even when there is no movement
            // We ignore these
            if (movement.x != 0 || movement.y != 0) {
                for handler in registeredMouseMoveHandlers {
                    handler.onMouseMove(globalLocation:globalLocation, movement:movement)
                }

                // raise a entityMouseDrag in case an entity was previously mouse-downed
                raiseEntityMouseDragEvent(globalLocation:globalLocation, movement:movement)
            }
        }
        previousMouseLocation = globalLocation
    }


    // ========== EntityMouseDownHandler ==========
    public func registerEntityMouseDownHandler(handler:EntityMouseDownHandler) {
        precondition(!registeredEntityMouseDownHandlers.contains(where: {$0.name == handler.name}), "registerEntityMouseDownHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredEntityMouseDownHandlers.append(handler)
    }

    public func unregisterEntityMouseDownHandler(handler:EntityMouseDownHandler) {
        precondition(registeredEntityMouseDownHandlers.contains(where: {$0.name == handler.name}), "unregisterEntityMouseDownHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredEntityMouseDownHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseEntityMouseDownEvent(globalLocation:Point) {
        // This is easy if there are no registered handlers
        if !registeredEntityMouseDownHandlers.isEmpty {
            guard let director = director else {
                fatalError("raiseEntityMouseDownEvent requires a director")
            }

            // We obtain an ordered list of all objects from front to back
            if let backToFrontList = director.backToFrontList(ignoreIsMouseTransparent:true) {
                let frontToBackList = backToFrontList.reversed()

                // Examine each entity in order from front to back
                // The first entity to report that the hitTest is true will receive the event
                // provided that it has a defined handler
                // Otherwise, this is likely an error
                for entity in frontToBackList {
                    if entity.hitTest(globalLocation:globalLocation) {
                        let matchingRegisteredEntities = registeredEntityMouseDownHandlers.filter {$0.name == entity.name}
                        precondition(matchingRegisteredEntities.count <= 1, "raiseEntityMouseDownEvent found non-unique entity names for '\(entity.name)'")
                        if matchingRegisteredEntities.count == 1 {
                            let handler = matchingRegisteredEntities[0]
                            handler.onEntityMouseDown(globalLocation:globalLocation)
                            mostRecentEntityMouseDownHandler = handler
                        } else {
                            print("WARNING: hitTest for entity '\(entity.name)' intercepted hit for raiseEntityMouseDown event but is unregistered")
                        }
                        break
                    }
                }
            }
        }
    }

    // ========== EntityMouseUpHandler ==========
    public func registerEntityMouseUpHandler(handler:EntityMouseUpHandler) {
        precondition(!registeredEntityMouseUpHandlers.contains(where: {$0.name == handler.name}), "registerEntityMouseUpHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredEntityMouseUpHandlers.append(handler)
    }

    public func unregisterEntityMouseUpHandler(handler:EntityMouseUpHandler) {
        precondition(registeredEntityMouseUpHandlers.contains(where: {$0.name == handler.name}), "unregisterEntityMouseUpHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredEntityMouseUpHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseEntityMouseUpEvent(globalLocation:Point) {
        // This is easy if there are no registered handlers
        if !registeredEntityMouseUpHandlers.isEmpty {
            guard let director = director else {
                fatalError("raiseEntityMouseUpEvent requires a director")
            }

            // We obtain an ordered list of all objects from front to back
            if let backToFrontList = director.backToFrontList(ignoreIsMouseTransparent:true) {
                let frontToBackList = backToFrontList.reversed()

                // Examine each entity in order from front to back
                // The first entity to report that the hitTest is true will receive the event
                // provided that it has a defined handler
                // Otherwise, this is likely an error
                for entity in frontToBackList {
                    if entity.hitTest(globalLocation:globalLocation) {
                        let matchingRegisteredEntities = registeredEntityMouseUpHandlers.filter {$0.name == entity.name}
                        precondition(matchingRegisteredEntities.count <= 1, "raiseEntityMouseUpEvent found non-unique entity names for '\(entity.name)'")
                        if matchingRegisteredEntities.count == 1 {
                            let handler = matchingRegisteredEntities[0]
                            handler.onEntityMouseUp(globalLocation:globalLocation)

                            // Raise a click event for this entity
                            raiseEntityMouseClickEvent(globalLocation:globalLocation, entityMouseUpHandler:handler)
                        } else {
                            print("WARNING: hitTest for entity '\(entity.name)' intercepted hit for raiseEntityMouseUp event but is unregistered")
                        }
                        break
                    }
                }
            }
        }
    }

    
    // ========== EntityMouseClickHandler ==========
    public func registerEntityMouseClickHandler(handler:EntityMouseClickHandler) {
        precondition(!registeredEntityMouseClickHandlers.contains(where: {$0.name == handler.name}), "registerEntityMouseClickHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredEntityMouseClickHandlers.append(handler)
    }

    public func unregisterEntityMouseClickHandler(handler:EntityMouseClickHandler) {
        precondition(registeredEntityMouseClickHandlers.contains(where: {$0.name == handler.name}), "unregisterEntityMouseClickHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredEntityMouseClickHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseEntityMouseClickEvent(globalLocation:Point, entityMouseUpHandler:EntityMouseUpHandler) {
        // This is easy if there are no registered handlers or if the upHandler was different than the downHandler
        if let mostRecentEntityMouseDownHandler = mostRecentEntityMouseDownHandler,
           !registeredEntityMouseClickHandlers.isEmpty && (mostRecentEntityMouseDownHandler.name == entityMouseUpHandler.name) {
            let matchingRegisteredEntities = registeredEntityMouseClickHandlers.filter {$0.name == entityMouseUpHandler.name}
            precondition(matchingRegisteredEntities.count <= 1, "raiseEntityMouseClickEvent found non-unique entity names for '\(entityMouseUpHandler.name)'")
            if matchingRegisteredEntities.count == 1 {
                let handler = matchingRegisteredEntities[0]
                handler.onEntityMouseClick(globalLocation:globalLocation)
            }
        }
    }
    
    // ========== EntityMouseDragHandler ==========
    public func registerEntityMouseDragHandler(handler:EntityMouseDragHandler) {
        precondition(!registeredEntityMouseDragHandlers.contains(where: {$0.name == handler.name}), "registerEntityMouseDragHandler() Unable to register handler '\(handler.name)' because it has already been registered.")
        registeredEntityMouseDragHandlers.append(handler)
    }

    public func unregisterEntityMouseDragHandler(handler:EntityMouseDragHandler) {
        precondition(registeredEntityMouseDragHandlers.contains(where: {$0.name == handler.name}), "unregisterEntityMouseDragHandler() Unable to unregister handler '\(handler.name)' because it isn't registered.")
        registeredEntityMouseDragHandlers.removeAll(where: {$0.name == handler.name})
    }

    internal func raiseEntityMouseDragEvent(globalLocation:Point, movement:Point) {
        // This is easy if there are no registered handlers or if there's no moseRecentEntityMouseDownHandler
        if let mostRecentEntityMouseDownHandler = mostRecentEntityMouseDownHandler,
           !registeredEntityMouseDragHandlers.isEmpty {
            let matchingRegisteredEntities = registeredEntityMouseDragHandlers.filter {$0.name == mostRecentEntityMouseDownHandler.name}
            precondition(matchingRegisteredEntities.count <= 1, "raiseEntityMouseDragEvent found non-unique entity names for '\(mostRecentEntityMouseDownHandler.name)'")
            if matchingRegisteredEntities.count == 1 {
                let handler = matchingRegisteredEntities[0]
                handler.onEntityMouseDrag(globalLocation:globalLocation, movement:movement)
            }
        }
    }
    
    

}
