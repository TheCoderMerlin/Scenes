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


// References: https://bugs.swift.org/browse/SR-55?focusedCommentId=28441&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-28441
//             https://stackoverflow.com/questions/33112559/protocol-doesnt-conform-to-itself

// This class provides a very thin wrapper around a protcol to provide us with a concrete object
// suitable for placing in the EventHandlers generic collection
internal class EventHandlerWrapper<EventHandlerType>  {
    private var _handler : AnyObject?

    var handler : EventHandlerType {
        guard let handler = _handler as? EventHandlerType else {
            fatalError("Failed to case handler")
        }
        return handler
    }

    init(handler: EventHandlerType) {
        self._handler = handler as AnyObject
    }
}
