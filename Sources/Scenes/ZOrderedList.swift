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

internal class ZOrderedList<T:Equatable>  {
    // Head refers to the beginning of the list
    // Tail refers to the end of the list
    internal var list : [T]

    init() {
        list = [T]()
    }

    var count : Int {
        return list.count
    }

    func objectIndex(object:T) -> Int? {
        return list.firstIndex(of:object)
    }

    func insert(atHead object:T) {
        list.insert(object, at:0)
    }

    func insert(atTail object:T) {
        list.insert(object, at:list.endIndex)
    }

    func insert(object:T, after:T) {
        guard let index = list.firstIndex(of:after)  else {
            fatalError("Failed to find object (after) in the specified list")
        }
        let insertionIndex = index + 1 == list.count ?
          list.endIndex :
          index + 1
        list.insert(object, at:insertionIndex)
    }

    func insert(object:T, before:T) {
        guard let index = list.firstIndex(of:before)  else {
            fatalError("Failed to find object (before) in the specified list")
        }
        list.insert(object, at:index)
    }

    func swap(_ index1:Int, _ index2:Int) {
        list.swapAt(index1, index2)
    }

    func insert(object:T, at zLocation:ZOrder<T>) {
        switch (zLocation) {
        case .back:
            insert(atHead:object)
        case .backward:
            fatalError("zLocation of .backward is not a valid option for insertion")
        case .behind(let behindObject):
            insert(object:object, before:behindObject)
        case .inFrontOf(let inFrontOfObject):
            insert(object:object, after:inFrontOfObject)
        case .forward:
            fatalError("zLocation of .forward is not a valid option for insertion")
        case .front:
            insert(atTail:object)
        }
    }

    public func moveZ(of object:T, to zLocation:ZOrder<T>) {
        guard let index = objectIndex(object:object) else {
            fatalError("Failed to find index object in the specified list")
        }

        switch (zLocation) {
        case .back:
            let object = list.remove(at:index)
            list.insert(object, at:0)
        case .backward:
            let otherIndex = index - 1
            if otherIndex >= 0 {
                swap(otherIndex, index)
            }
        case .behind(let behindObject):
            guard let otherIndex = objectIndex(object:behindObject) else {
                fatalError("Failed to find index (behind) in the specified list")
            }
            swap(otherIndex, index)
        case .inFrontOf(let inFrontOfObject):
            guard let otherIndex = objectIndex(object:inFrontOfObject) else {
                fatalError("Failed to find index of object (inFrontOf) in the specified list")
            }
            swap(otherIndex, index)
        case .forward:
            let otherIndex = index + 1
            if otherIndex < count {
                swap(otherIndex, index)
            }
        case .front:
            let object = list.remove(at:index)
            list.append(object)
        }
    }
}

