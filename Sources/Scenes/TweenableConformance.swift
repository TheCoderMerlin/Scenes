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
import Igis

extension Int : Tweenable {
    public func lerp(to target:Int, percent:Double) -> Int {
        return self + Int(Double(target - self) * percent)
    }

    public func interval(to target:Int) -> Double {
        return Double(abs(target - self))
    }
}

extension Double : Tweenable {
    public func lerp(to target:Double, percent:Double) -> Double {
        return self + (target - self) * percent
    }

    public func interval(to target:Double) -> Double {
        return abs(target - self)
    }
}

extension Point : Tweenable {
    // lerp is already defined within Igis
    public func interval(to target:Point) -> Double {
        return self.distance(to:target)
    }
}

extension Size : Tweenable {
    // lerp is already defined within Igis
    public func interval(to target:Size) -> Double {
        let widthDifferenceSquared = pow(Double(target.width-width), 2)
        let heightDifferenceSquared = pow(Double(target.height-height), 2)
        return sqrt(widthDifferenceSquared + heightDifferenceSquared)
    }
}

extension Color : Tweenable {
    // lerp is already defined within Igis
    public func interval(to target:Color) -> Double {
        return (Double(target.red) - Double(red)) + (Double(target.green) - Double(green)) + (Double(target.blue) - Double(blue))
    }
}
