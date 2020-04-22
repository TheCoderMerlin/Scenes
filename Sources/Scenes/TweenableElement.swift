public protocol TweenableElement {
    func lerp(end:Self, fraction:Double) -> Self
    func distance(to target:Self) -> Double
}
