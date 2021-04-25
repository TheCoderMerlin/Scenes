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

/// `IdentifiableObject` provides base functionality for using unique
/// names that are useful for debugging.
open class IdentifiableObject : Equatable {
    private let uniqueName : UniqueName

    /// Creates a new `IdentifiableObject` from the specified parameters.
    /// - Parameters:
    ///   - name: a non-unique name to use while generating unique name for object.
    public init(name:String?=nil) {
        uniqueName = UniqueName(objectType:Self.self, name:name)
    }

    /// A unique name associated with the object.
    public var name : String {
        return uniqueName.fullname
    }

    /// Equivalence operator for two `IdentifiableObject`s.
    public static func == (left: IdentifiableObject, right: IdentifiableObject) -> Bool {
        return left.name == right.name
    }
}
