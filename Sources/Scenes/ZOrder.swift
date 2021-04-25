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

public enum ZOrder<T> {
    /// Place (or move) the object at the back-most position.
    case back
    /// Place (or move) the object backward from its current position.
    case backward
    /// Place (or move) the object behind the specified object.
    case behind(object:T)
    /// Place (or move) the object in front of the specified object.
    case inFrontOf(object:T)
    /// Place (or move) the object foreward from its current position
    case forward
    /// Place (or move) the object to the front-most position
    case front
}
