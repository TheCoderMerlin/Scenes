// Any element that conforms to Tweenable protocol can be utilized in a Tween
public protocol Tweenable {
    
    // generates a new value between self and target at the specified percent between the two values
    func lerp(to target:Self, percent:Double) -> Self

    // generates interval to other value for calculating speed based tweens
    func interval(to target:Self) -> Double
}
