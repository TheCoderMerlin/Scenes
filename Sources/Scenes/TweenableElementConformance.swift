import Igis

// default extensions to allow for more versatility in animated objects include Int, Double, and Float types
extension Int : TweenableElement {
    public func lerp(to target:Int, percent:Double) -> Int {
        return self + Int(Double(target - self) * percent)
    }

    public func distance(to target:Int) -> Double {
        return Double(abs(target - self))
    }
}

extension Double : TweenableElement {
    public func lerp(to target:Double, percent:Double) -> Double {
        return self + (target - self) * percent
    }

    public func distance(target:Double) -> Double {
        return abs(target - self)
    }
}

extension Float : TweenableElement {
    public func lerp(to target:Float, percent:Double) -> Float {
        return self + target - self * Float(percent)
    }
    
    public func distance(to target:Float) -> Double {
        return Double(abs(target - self))
    }
}

// Igis elements which already conform to TweenableElement protocol
extension Point : TweenableElement {}

extension Size : TweenableElement {}
