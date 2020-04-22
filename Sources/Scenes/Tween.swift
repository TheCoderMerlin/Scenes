public class Tween<TweenElementType: TweenableElement> : InternalTweenProtocol {
    private let startValue : TweenElementType
    private let endValue : TweenElementType
    
    public let duration : Double
    public let ease : EasingStyle

    var updateHandler : (TweenElementType) -> () = {_ in}

    public init(from:TweenElementType, to:TweenElementType, duration:Double = 1, ease:EasingStyle = .linear, update:@escaping (TweenElementType) -> ()) {
        self.startValue = from
        self.endValue = to
        self.duration = duration
        self.ease = ease
        self.updateHandler = update
    }

    public init(from:TweenElementType, to:TweenElementType, speed:Double, ease:EasingStyle = .linear, update:@escaping (TweenElementType) -> ()) {
        var distance = from.distance(to:to)
        if distance < 0 {
            assert(true, "Distance returned from distance() in \(type(of:from)) must be positive.")
            distance = -distance
        }
        
        self.startValue = from
        self.endValue = to
        self.duration = distance / speed
        self.ease = ease
        self.updateHandler = update
    }
    
    internal func update(fraction:Double) {
        let newValue = startValue.lerp(end:endValue, fraction:ease.apply(fraction:fraction))
        updateHandler(newValue)
    }
}
