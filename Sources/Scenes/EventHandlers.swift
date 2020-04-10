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

// This class is used to maintain a list of registered handlers for a specific event
internal class EventHandlers<EventHandlerType> {
    typealias EventHandlerWrapperType = EventHandlerWrapper<EventHandlerType>
    
    private var list : [EventHandlerWrapperType]

    init() {
        list = []
    }

    // This function is required because EventHandlerType (despite the name) isn't really an EventHandler
    // However, if we try to constrain the EventHandlerType (i.e. EventHandlerType : EventHandler) we'll
    // no longer be able to use this generic class because we'll receive the error:
    //      protocol type 'KeyDownHandler' cannot conform to 'EventHandler' because only concrete types can conform to protocols
    // This, in conjunction with EventHandlerWrapper is a work-around but it does enable us to significantly
    // reduce the required code in the dispatcher
    private func handler(_ eventHandler:EventHandlerType) -> EventHandler {
        guard let eventHandler = eventHandler as? EventHandler else {
            fatalError("Failed to cast hander as EventHandler")
        }
        return eventHandler
    }

    var count : Int {
        return list.count
    }

    var isEmpty : Bool {
        return count == 0
    }

    // attempts to find the handler with the specified name in the list
    // if found, returns the handler, otherwise, returns nil
    func find(handlerName:String) -> EventHandlerType? {
        let foundHandlers = list.filter {handler($0.handler).name == handlerName}
        precondition(foundHandlers.count <= 1, "Found duplicate handlers for '\(handlerName)'")
        return foundHandlers.first?.handler
    }
    
    // returns true iff the specified eventHandler is found in the list
    func exists(_ eventHandler:EventHandlerType) -> Bool {
        return list.contains(where: {handler($0.handler).name == handler(eventHandler).name})
    }

    // adds the specified handler to the list after ensuring that it isn't already present
    func register(_ eventHandler:EventHandlerType) {
        guard !exists(eventHandler) else {
            fatalError("Unable to register specified handler '\(handler(eventHandler).name)' because it is already registered.")
        }
        let wrapper : EventHandlerWrapperType = EventHandlerWrapperType(handler:eventHandler)
        list.append(wrapper)
    }

    // removes the specified handler form the list after ensuring that it is present
    func unregister(_ eventHandler:EventHandlerType) {
        guard exists(eventHandler) else {
            fatalError("Unable to register specified handler '\(handler(eventHandler).name)' because it isn't registered.")
        }
        list.removeAll(where: {handler($0.handler).name == handler(eventHandler).name})
    }

    // executes the specifed statement for each handler in the listp
    func forEach(_ doStatement:(EventHandlerType) -> ()) {
        for wrapper in list {
            doStatement(wrapper.handler)
        }
    }

    
    
}
