public class Animation : Equatable {
    enum State {
        case notQueued
        case queued
        case playing
        case playingInReverse
        case paused
        case pausedInReverse
        case completed
        case cancelled
    }
    internal var state = State.notQueued

    private let tween : InternalTweenProtocol
    private var elapsedTime = 0.0

    public var loop = false
    public var reverse = false

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
            let percent = elapsedTime / tween.duration
            tween.update(percent:percent)
            
            if percent >= 1 {
                if reverse {
                    state = .playingInReverse
                } else if loop {
                    restart()
                } else {
                    state = .completed
                }
            }
            
            elapsedTime += frameRate
        } else if state == .playingInReverse {
            let percent = elapsedTime / tween.duration
            tween.update(percent:percent)
            
            if percent <= 0 {
                if loop {
                    restart()
                } else {
                    state = .completed
                }
            }
            
            elapsedTime -= frameRate
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public var isCompleted : Bool {
        return state == .completed || state == .cancelled
    }

    public var isPaused : Bool {
        return state == .paused || state == .pausedInReverse
    }

    public var isPlaying : Bool {
        return state == .playing || state == .playingInReverse || state == .queued
    }

    public var isQueued : Bool {
        return state != .notQueued
    }

    public var inverse : Animation {
        let tween = self.tween.inverse()
        return Animation(tween:tween)
    }

    public func terminate() {
        if isQueued {
            state = .cancelled
        }
    }

    public func pause() {
        if isPlaying {
            if state == .playingInReverse {
                state = .pausedInReverse
            } else {
                state = .paused
            }
        }
    }

    public func play() {
        if !isCompleted && !isPlaying {
            if isQueued {
                if state == .pausedInReverse {
                    state = .playingInReverse
                } else {
                    state = .playing
                }
            } else {
                state = .queued
            }
        }
    }

    public func restart() {
        if isPlaying {
            state = .playing
        } else {
            state = .notQueued
        }
        self.elapsedTime = 0
    }

    static public func == (lhs:Animation, rhs:Animation) -> Bool {
        return lhs === rhs
    }
}
