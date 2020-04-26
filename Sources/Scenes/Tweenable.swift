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


/// Any element that conforms to 'Tweenable' can be utilized in a 'Tween'.
public protocol Tweenable {
    /// Calculates a new element of certain percentage between this element and another
    /// - Parameters:
    ///   - target: the target element of which to calculate the new element between
    ///   - percent: value between 0 and 1 representing percentage
    /// - Returns: A new element of percent between this element and a target element
    func lerp(to target:Self, percent:Double) -> Self

    /// Calculates the interval between this element and another
    /// - Parameters:
    ///   - target: The target element of which to calculate the interval
    /// - Returns: The distance to a target element
    func interval(to target:Self) -> Double
}
