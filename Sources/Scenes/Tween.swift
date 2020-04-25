public class Tween<TweenElement: Tweenable> : InternalTweenProtocol {
    private let startValue : TweenElement
    private let endValue : TweenElement
    
    public let duration : Double
    public let ease : EasingStyle

    var updateHandler : (TweenElement) -> () = {_ in}

    public init(from:TweenElement, to:TweenElement, duration:Double = 1, ease:EasingStyle = .linear, update:@escaping (TweenElement) -> ()) {
        self.startValue = from
        self.endValue = to
        self.duration = duration
        self.ease = ease
        self.updateHandler = update
    }

    public init(from:TweenElement, to:TweenElement, speed:Double, ease:EasingStyle = .linear, update:@escaping (TweenElement) -> ()) {
        var interval = from.interval(to:to)
        if interval < 0 {
            assert(true, "Distance returned from distance() in \(type(of:from)) must be positive.")
            interval = -interval
        }
        
        self.startValue = from
        self.endValue = to
        self.duration = interval / speed
        self.ease = ease
        self.updateHandler = update
    }
    
    internal func update(percent:Double) {
        let easePercent = ease.apply(percent:percent)
        let newValue = startValue.lerp(to:endValue, percent:easePercent)
        updateHandler(newValue)
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    internal func inverse() -> InternalTweenProtocol {
        return Tween(from:endValue, to:startValue, duration:duration, ease:ease.inverse(), update:updateHandler)
    }
}
