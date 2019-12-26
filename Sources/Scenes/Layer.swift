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

class Layer {

    private var backToFrontRecords : RenderableEntityRecordList

    init() {
        backToFrontRecords = RenderableEntityRecordList()
    }

    func insert(entity:RenderableEntityProtocol, at zLocation:ZLocation) {
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

    func moveZ(of entity:RenderableEntityProtocol, zLocation:ZLocation) {
    }
}

