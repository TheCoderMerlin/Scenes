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

open class Layer {

    private var backToFrontRecords : RenderableEntityRecordList

    public init() {
        backToFrontRecords = RenderableEntityRecordList()
    }

    public func insert(entity:RenderableEntityBase, at zLocation:ZOrder<RenderableEntityBase>) {
        let entityRecord = RenderableEntityRecord(renderableEntity:entity)
        
        switch (zLocation) {
        case .back:
            backToFrontRecords.insert(atHead:entityRecord)
        case .backward:
            fatalError("zLocation of .backward is not a valid option for insertion")
        case .behind(let behindEntity):
            guard let behindEntityRecord = backToFrontRecords.entityRecord(entity:behindEntity) else {
                fatalError("Unable to find specified behindEntity in this layer")
            }
            backToFrontRecords.insert(entityRecord:entityRecord, before:behindEntityRecord)
        case .inFrontOf(let inFrontOfEntity):
            guard let inFrontOfEntityRecord = backToFrontRecords.entityRecord(entity:inFrontOfEntity) else {
                fatalError("Unable to find specified inFrontOfEntity in this layer")
            }
            backToFrontRecords.insert(entityRecord:entityRecord, after:inFrontOfEntityRecord)
        case .forward:
            fatalError("zLocation of .forard is not a valid option for insertion")
        case .front:
            backToFrontRecords.insert(atTail:entityRecord)
        }
    }

    public func moveZ(of entity:RenderableEntityBase, to zLocation:ZOrder<RenderableEntityBase>) {
        guard let entityRecordIndex = backToFrontRecords.entityRecordIndex(entity:entity) else {
            fatalError("Failed to find renderableEntityRecord in the specified list")
        }

        switch (zLocation) {
        case .back:
            let otherRecordIndex = 0
            backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
        case .backward:
            let otherRecordIndex = entityRecordIndex - 1
            if otherRecordIndex >= 0 {
                backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
            }
        case .behind(let behindEntity):
            guard let otherRecordIndex = backToFrontRecords.entityRecordIndex(entity:behindEntity) else {
                fatalError("Failed to find renderableEntityRecord in the specified list (behindEntity)")
            }
            backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
        case .inFrontOf(let inFrontOfEntity):
            guard let otherRecordIndex = backToFrontRecords.entityRecordIndex(entity:inFrontOfEntity) else {
                fatalError("Failed to find renderableEntityRecord in the specified list (inFrontOfEntity)")
            }
            backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
        case .forward:
            let otherRecordIndex = entityRecordIndex + 1
            if otherRecordIndex < backToFrontRecords.count {
                backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
            }
        case .front:
            let otherRecordIndex = backToFrontRecords.count - 1
            backToFrontRecords.swap(otherRecordIndex, entityRecordIndex)
        }
    }
}

extension Layer : Equatable {
    public static func == (lhs:Layer, rhs: Layer) -> Bool {
        return lhs === rhs
    }
}
