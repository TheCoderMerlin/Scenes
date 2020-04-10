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
    private var registeredKeyDownHandlers = EventHandlers<KeyDownHandler>()
    private var registeredKeyUpHandlers   = EventHandlers<KeyUpHandler>()

    // Resize Handlers
    private var registeredCanvasResizeHandlers = EventHandlers<CanvasResizeHandler>()
    private var registeredWindowResizeHandlers = EventHandlers<WindowResizeHandler>()

    // Mouse Handlers
    private var registeredMouseDownHandlers = EventHandlers<MouseDownHandler>()
    private var registeredMouseUpHandlers   = EventHandlers<MouseUpHandler>()
    private var registeredMouseMoveHandlers = EventHandlers<MouseMoveHandler>()

    // Entity Mouse Handlers
    private var registeredEntityMouseDownHandlers  = EventHandlers<EntityMouseDownHandler>()
    private var registeredEntityMouseUpHandlers    = EventHandlers<EntityMouseUpHandler>()
    private var registeredEntityMouseClickHandlers = EventHandlers<EntityMouseClickHandler>()
    private var registeredEntityMouseDragHandlers  = EventHandlers<EntityMouseDragHandler>()
    private var registeredEntityMouseEnterHandlers = EventHandlers<EntityMouseEnterHandler>()
    private var registeredEntityMouseLeaveHandlers = EventHandlers<EntityMouseLeaveHandler>()

    // Keep track of the name for EntityMouseClick/EntityMouseDrag events
    private var mostRecentEntityNameForMouseClickOrDrag : String? = nil

    // Keep track of the name for EntityMouseEnter/EntityMouseLeave events
    private var mostRecentEntityNameForMouseEnterOrLeave : String? = nil

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
        debugListRegisteredHandlers(handlers:registeredEntityMouseEnterHandlers, name:"entityMouseEnter")
        debugListRegisteredHandlers(handlers:registeredEntityMouseLeaveHandlers, name:"entityMouseLeave")
    }
    
    internal func debugListRegisteredHandlers<EventHandlerType>(handlers:EventHandlers<EventHandlerType>, name:String) {
        if !handlers.isEmpty {
            print("========== \(name) handlers")
            handlers.forEach {
                guard let handler = $0 as? EventHandler else {
                    fatalError("Failed to cast handler as EventHandler")
                }
                print("\t\(handler.name)") }
        }
    }

    internal func frontMostEntity(atGlobalLocation globalLocation:Point, ignoreIsMouseTransparent:Bool) -> RenderableEntity? {
        guard let director = director else {
            fatalError("frontMostEntity requires a director")
        }
        return director.frontMostEntity(atGlobalLocation:globalLocation, ignoreIsMouseTransparent:ignoreIsMouseTransparent) 
    }

    // ========== KeyDownHandler ==========
    public func registerKeyDownHandler(handler:KeyDownHandler) {
        registeredKeyDownHandlers.register(handler)
    }

    public func unregisterKeyDownHandler(handler:KeyDownHandler) {
        registeredKeyDownHandlers.unregister(handler)
    }

    internal func raiseKeyDownEvent(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        registeredKeyDownHandlers.forEach {$0.onKeyDown(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)}
    }

    // ========== KeyUpHandler ==========
    public func registerKeyUpHandler(handler:KeyUpHandler) {
        registeredKeyUpHandlers.register(handler)
    }

    public func unregisterKeyUpHandler(handler:KeyUpHandler) {
        registeredKeyUpHandlers.unregister(handler)
    }

    internal func raiseKeyUpEvent(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        registeredKeyUpHandlers.forEach {$0.onKeyUp(key:key, code:code, ctrlKey:ctrlKey, shiftKey:shiftKey, altKey:altKey, metaKey:metaKey)}
    }
    
    // ========== MouseDownHandler ==========
    public func registerMouseDownHandler(handler:MouseDownHandler) {
        registeredMouseDownHandlers.register(handler)
    }

    public func unregisterMouseDownHandler(handler:MouseDownHandler) {
        registeredMouseDownHandlers.unregister(handler)
    }

    internal func raiseMouseDownEvent(globalLocation:Point) {
        registeredMouseDownHandlers.forEach {$0.onMouseDown(globalLocation:globalLocation)}

        // Raise the event for entities
        raiseEntityMouseDownEvent(globalLocation:globalLocation)
    }
    
    // ========== MouseUpHandler ==========
    public func registerMouseUpHandler(handler:MouseUpHandler) {
        registeredMouseUpHandlers.register(handler)
    }

    public func unregisterMouseUpHandler(handler:MouseUpHandler) {
        registeredMouseUpHandlers.unregister(handler)
    }

    internal func raiseMouseUpEvent(globalLocation:Point) {
        registeredMouseUpHandlers.forEach {$0.onMouseUp(globalLocation:globalLocation)}

        // Raise the event for entities
        raiseEntityMouseUpEvent(globalLocation:globalLocation)

        // Clear the most recent name for handling clicks and drags
        mostRecentEntityNameForMouseClickOrDrag = nil
    }

    // ========== WindowMouseUpHandler ==========
    internal func raiseWindowMouseUpEvent(globalLocation:Point) {
        // This handles the cancellation of any pending click, because the mouseUp event
        // occurred outside of the canvas
        // The coordinates match that of the canvas, so we simply relay this event
        raiseMouseUpEvent(globalLocation:globalLocation)
    }
    
    // ========== MouseMoveHandler ==========
    public func registerMouseMoveHandler(handler:MouseMoveHandler) {
        registeredMouseMoveHandlers.register(handler)
    }

    public func unregisterMouseMoveHandler(handler:MouseMoveHandler) {
        registeredMouseMoveHandlers.unregister(handler)
    }

    internal func raiseMouseMoveEvent(globalLocation:Point) {
        if let previousMouseLocation = previousMouseLocation {
            let movement = Point(x:globalLocation.x-previousMouseLocation.x,y:globalLocation.y-previousMouseLocation.y)
            // We sometimes receive this "Move" event even when there is no movement
            // We ignore these
            if (movement.x != 0 || movement.y != 0) {
                registeredMouseMoveHandlers.forEach {$0.onMouseMove(globalLocation:globalLocation, movement:movement)}

                // raise a entityMouseDrag in case an entity was previously mouse-downed
                raiseEntityMouseDragEvent(globalLocation:globalLocation, movement:movement)

                // raise an entityMouseEnterLeave is case an entity wants these events
                raiseEntityMouseEnterLeaveHandler(globalLocation:globalLocation)
            }
        }
        previousMouseLocation = globalLocation
    }

    // ========== CanvasResizeHandler ==========
    public func registerCanvasResizeHandler(handler:CanvasResizeHandler) {
        registeredCanvasResizeHandlers.register(handler)
    }

    public func unregisterCanvasResizeHandler(handler:CanvasResizeHandler) {
        registeredCanvasResizeHandlers.unregister(handler)
    }

    internal func raiseCanvasResizeEvent(size:Size) {
        registeredCanvasResizeHandlers.forEach {$0.onCanvasResize(size:size)}
    }

    // ========== WindowResizeHandler ==========
    public func registerWindowResizeHandler(handler:WindowResizeHandler) {
        registeredWindowResizeHandlers.register(handler)
    }

    public func unregisterWindowResizeHandler(handler:WindowResizeHandler) {
        registeredWindowResizeHandlers.unregister(handler)
    }

    internal func raiseWindowResizeEvent(size:Size) {
        registeredWindowResizeHandlers.forEach {$0.onWindowResize(size:size)}
    }


    // ========== EntityMouseDownHandler ==========
    public func registerEntityMouseDownHandler(handler:EntityMouseDownHandler) {
        registeredEntityMouseDownHandlers.register(handler)
    }

    public func unregisterEntityMouseDownHandler(handler:EntityMouseDownHandler) {
        registeredEntityMouseDownHandlers.unregister(handler)
    }

    internal func raiseEntityMouseDownEvent(globalLocation:Point) {
        // We only need to proceed if we have either EntityMouseDown, EntityMouseClick, or EntityMouseDrag handlers
        if !registeredEntityMouseDownHandlers.isEmpty || !registeredEntityMouseClickHandlers.isEmpty || !registeredEntityMouseDragHandlers.isEmpty {
            // Find the frontMostEntity (if any).  This entity will receive the event(s) provided that it's defined a handler
            if let entity = frontMostEntity(atGlobalLocation:globalLocation, ignoreIsMouseTransparent:true) {
                
                // Find a candidates for EntityMouseDown, EntityMouseClick, and EntityMouseDrag which may (or may not defined) for this object
                let entityMouseDownHandler  = registeredEntityMouseDownHandlers.find(handlerName:entity.name)
                let entityMouseClickHandler = registeredEntityMouseClickHandlers.find(handlerName:entity.name)
                let entityMouseDragHandler  = registeredEntityMouseDragHandlers.find(handlerName:entity.name)

                // Track to see if we consume the event so that we can offer a helpful error message
                var eventWasConsumed = false

                // Handle EntityMouseDown
                if let handler = entityMouseDownHandler {
                    handler.onEntityMouseDown(globalLocation:globalLocation)
                    eventWasConsumed = true
                }

                // and/or handle EntityMouseDrag or EntityMouseClick
                if entityMouseClickHandler != nil || entityMouseDragHandler != nil {
                    mostRecentEntityNameForMouseClickOrDrag = entity.name
                    eventWasConsumed = true
                }

                if !eventWasConsumed {
                    print("WARNING: hitTest for entity '\(entity.name)' intercepted hit for raiseEntityMouseDown/Click/Drag event but is unregistered")
                }
            }
        }
    }

    // ========== EntityMouseEnterHandler ==========
    public func registerEntityMouseEnterHandler(handler:EntityMouseEnterHandler) {
        registeredEntityMouseEnterHandlers.register(handler)
    }

    public func unregisterEntityMouseEnterHandler(handler:EntityMouseEnterHandler) {
        registeredEntityMouseEnterHandlers.unregister(handler)
    }

    internal func raiseEntityMouseEnterLeaveHandler(globalLocation:Point) {
        // We only need to proceed if we have an entityMouseEnter/entityMouseLeave handler
        if !registeredEntityMouseEnterHandlers.isEmpty || !registeredEntityMouseLeaveHandlers.isEmpty {
            // Find the frontMostEntity
            let entity = frontMostEntity(atGlobalLocation:globalLocation, ignoreIsMouseTransparent:true)

            // If we currently have an entity which received an enter and we are no longer on that entity,
            // we issue a mouseLeave (it it handles this event)
            if let mostRecentEntityNameForMouseEnterOrLeave = mostRecentEntityNameForMouseEnterOrLeave,
               entity == nil || (entity!.name != mostRecentEntityNameForMouseEnterOrLeave),
               let handler = registeredEntityMouseLeaveHandlers.find(handlerName:mostRecentEntityNameForMouseEnterOrLeave) {
                handler.onEntityMouseLeave(globalLocation:globalLocation)
            }
            
            // If we have a frontMostEntity which is different than the current entity,
            // we issue a mouseEnter (if it handles this event)
            if let entity = entity,
               (mostRecentEntityNameForMouseEnterOrLeave == nil) || (mostRecentEntityNameForMouseEnterOrLeave! != entity.name),
                let handler = registeredEntityMouseEnterHandlers.find(handlerName:entity.name) {
                    handler.onEntityMouseEnter(globalLocation:globalLocation)
            }
            
            // Set the new most recent entity to the frontMost entity (if any)
            self.mostRecentEntityNameForMouseEnterOrLeave = entity?.name
        }
    }

    
    // ========== EntityMouseEnterLeave ==========
    public func registerEntityMouseLeaveHandler(handler:EntityMouseLeaveHandler) {
        registeredEntityMouseLeaveHandlers.register(handler)
    }

    public func unregisterEntityMouseLeaveHandler(handler:EntityMouseLeaveHandler) {
        registeredEntityMouseLeaveHandlers.unregister(handler)
    }

    // Note:  This event is raised by raiseEntityMouseEnterLeaveHandler
    /*
    internal func raiseEntityMouseLeaveHandler(globalLocation:Point) {
        
    }
     */
    

    // ========== EntityMouseUpHandler ==========
    public func registerEntityMouseUpHandler(handler:EntityMouseUpHandler) {
        registeredEntityMouseUpHandlers.register(handler)
    }

    public func unregisterEntityMouseUpHandler(handler:EntityMouseUpHandler) {
        registeredEntityMouseUpHandlers.unregister(handler)
    }

    internal func raiseEntityMouseUpEvent(globalLocation:Point) {
        // We only need to proceed if we have either EntityMouseUpHandlers or EntityMouseClickHandlers
        if !registeredEntityMouseUpHandlers.isEmpty || !registeredEntityMouseClickHandlers.isEmpty {
            // Find the frontMostEntity (if any).  This entity will receive the event(s) provided that it's defined a handler
            if let entity = frontMostEntity(atGlobalLocation:globalLocation, ignoreIsMouseTransparent:true) {
                // Find a candidate for EntityMouseUp
                let entityMouseUpHandler = registeredEntityMouseUpHandlers.find(handlerName:entity.name)

                // Track to see if we consume the event so that we can offer a helpful error message
                var wasEventConsumed = false

                // Handle EntityMouseClick
                if let mostRecentEntityNameForMouseClickOrDrag = mostRecentEntityNameForMouseClickOrDrag,
                   entity.name == mostRecentEntityNameForMouseClickOrDrag {
                    // Find a candiate for EntityMouseClick
                    let entityMouseClickHandler = registeredEntityMouseClickHandlers.find(handlerName:entity.name)

                    if let handler = entityMouseClickHandler {
                        handler.onEntityMouseClick(globalLocation:globalLocation)
                        wasEventConsumed = true
                    }
                }
                
                // and/or Handle EntityMouseUp
                if let handler = entityMouseUpHandler {
                    handler.onEntityMouseUp(globalLocation:globalLocation)
                    wasEventConsumed = true
                }

                if !wasEventConsumed {
                    print("WARNING: hitTest for entity '\(entity.name)' intercepted hit for raiseEntityMouseUp/Click event but is unregistered")
                }

            }
        }
    }
    
    // ========== EntityMouseClickHandler ==========
    public func registerEntityMouseClickHandler(handler:EntityMouseClickHandler) {
        registeredEntityMouseClickHandlers.register(handler)
    }

    public func unregisterEntityMouseClickHandler(handler:EntityMouseClickHandler) {
        registeredEntityMouseClickHandlers.unregister(handler)
    }

    /* NOTE:  This event is raised by raiseEntityMouseUpEvent
    internal func raiseEntityMouseClickEvent(globalLocation:Point, entityMouseUpHandler:EntityMouseUpHandler) {
    
    }
     */
    
    // ========== EntityMouseDragHandler ==========
    public func registerEntityMouseDragHandler(handler:EntityMouseDragHandler) {
        registeredEntityMouseDragHandlers.register(handler)
    }

    public func unregisterEntityMouseDragHandler(handler:EntityMouseDragHandler) {
        registeredEntityMouseDragHandlers.unregister(handler)
    }

    internal func raiseEntityMouseDragEvent(globalLocation:Point, movement:Point) {
        // This is easy if there is not a mostRecentEntityNameFrMouseClickOrDrag or there are no registered handlers 
        if let mostRecentEntityNameForMouseClickOrDrag = mostRecentEntityNameForMouseClickOrDrag,
           !registeredEntityMouseDragHandlers.isEmpty {
            let entityMouseDragHandler = registeredEntityMouseDragHandlers.find(handlerName:mostRecentEntityNameForMouseClickOrDrag)

            if let handler = entityMouseDragHandler {
                handler.onEntityMouseDrag(globalLocation:globalLocation, movement:movement)
            }
        }
    }
    
}
