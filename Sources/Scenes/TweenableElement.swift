// Any element that conforms to TweenableElement protocol can be utilized in a Tween.  Special cases must be defined within conforming functions.
public protocol TweenableElement {
    // called to generate a value between self and target at a certain point (percent) between the values
    func lerp(to target:Self, percent:Double) -> Self

    // returns distance to other value for calculating speed based actions
    func distance(to target:Self) -> Double
}
