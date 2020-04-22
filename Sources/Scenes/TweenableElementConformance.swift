import Igis

extension Double : TweenableElement {
    public func lerp(end:Double, fraction:Double) -> Double {
        return self + (end - self) * fraction
    }

    public func distance(target:Double) -> Double {
        return abs(target - self)
    }
}

extension Int : TweenableElement {
    public func lerp(end:Int, fraction:Double) -> Int {
        return self + Int(Double(end - self) * fraction)
    }

    public func distance(to target:Int) -> Double {
        return Double(abs(target - self))
    }
}

extension Point : TweenableElement {}

extension Size : TweenableElement {}
