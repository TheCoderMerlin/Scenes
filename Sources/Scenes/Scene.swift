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

open class Scene {

    private var backToFrontLayers : LayerList

    public init() {
        backToFrontLayers = LayerList()
    }

    public func insert(layer:Layer, at zLocation:ZOrder<Layer>) {
        switch (zLocation) {
        case .back:
            backToFrontLayers.insert(atHead:layer)
        case .backward:
            fatalError("zOrder of .backward is not a valid option for insertion")
        case .behind(let behindLayer):
            backToFrontLayers.insert(layer:layer, before:behindLayer)
        case .inFrontOf(let inFrontOfLayer):
            backToFrontLayers.insert(layer:layer, after:inFrontOfLayer)
        case .forward:
            fatalError("zOrder of .foward is not a valid option for insertion")
        case .front:
            backToFrontLayers.insert(atTail:layer)
        }
    }
    
}

