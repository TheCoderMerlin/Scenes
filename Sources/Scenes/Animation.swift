public class Animation : Equatable {
    enum State {
        case notQueued
        case queued
        case playing
        case paused
        case completed
        case cancelled
    }
    internal var state : State = .notQueued

    private let tween : InternalTweenProtocol!
    private var elapsedTime : Double = 0.0

    public init(tween:TweenProtocol) {
        guard let tween = tween as? InternalTweenProtocol else {
            fatalError("tween doesn't conform to InternalTweenProtocol.")
        }
        self.tween = tween
    }

    internal func updateFrame(frameRate:Double) {
        // if animation has been queued, begin playing
        if state == .queued {
            state = .playing
        }

        if state == .playing {
            let fraction = elapsedTime/tween.duration
            tween.update(fraction:fraction)
            
            if fraction >= 1 {
                state = .completed
            }
            
            elapsedTime += frameRate
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public var isCompleted : Bool {
        return state == .completed || state == .cancelled
    }

    public func terminate() {
        if state != .completed {
            state = .cancelled
        }
    }

    public func pause() {
        if state != .completed && state != .cancelled {
            state = .paused
        }
    }

    public func play() {
        if state == .notQueued {
            state = .queued
        } else {
            state = .playing
        }
    }

    static public func == (lhs:Animation, rhs:Animation) -> Bool {
        return lhs === rhs
    }
}
