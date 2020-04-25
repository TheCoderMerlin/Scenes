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
