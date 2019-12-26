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

class RenderableEntityRecordList {
    // Head refers to the beginning of the list
    // Tail refers to the end of the list
    private var list : [RenderableEntityRecord]

    init() {
        list = [RenderableEntityRecord]()
    }

    func entityRecord(entity:RenderableEntityProtocol) -> RenderableEntityRecord? {
        return list.first(where: {$0.renderableEntity === entity})
    }

    func insert(atHead entityRecord:RenderableEntityRecord) {
        list.insert(entityRecord, at:0)
    }

    func insert(atTail entityRecord:RenderableEntityRecord) {
        list.insert(entityRecord, at:list.endIndex)
    }

    func insert(entityRecord:RenderableEntityRecord, after:RenderableEntityRecord) {
        guard let index = list.firstIndex(of:after)  else {
            fatalError("Failed to find renderableEntityRecord in the specified list")
        }
        let insertionIndex = index + 1 == list.count ?
          list.endIndex :
          index + 1
        list.insert(entityRecord, at:insertionIndex)
    }

    func insert(entityRecord:RenderableEntityRecord, before:RenderableEntityRecord) {
        guard let index = list.firstIndex(of:before)  else {
            fatalError("Failed to find renderableEntityRecord in the specified list")
        }
        list.insert(entityRecord, at:index)
    }


    
}
