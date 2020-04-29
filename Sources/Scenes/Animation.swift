/*
 Scenes provides a Swift object library with support for renderable entities,
 layers, and scenes.  Scenes runs on top of IGIS.
 Copyright (C) 2020 Tango Golf Digital, LLC
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


/// An 'Animation' is used to animate elements using the 'AnimationManager'.

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

    /// Specifies whether or not to loop the animation over and over again until 'terminate()' is called.
    public var loop = false
    /// Specifies whether or not to reverse the animation after the animation is completete.
    public var reverse = false

    /// Creates a new 'Animation' from the specified 'Tween'
    /// - Parameters:
    ///   - tween: The 'Tween'
    public init(tween:TweenProtocol) {
        guard let tween = tween as? InternalTweenProtocol else {
            fatalError("tween doesn't conform to InternalTweenProtocol.")
        }
        self.tween = tween
    }

    internal init(tween:InternalTweenProtocol) {
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

    /// returns true if the animation was completed or cancelled
    ///
    /// NB: will only return true for one frame when animation is completed
    public var isCompleted : Bool {
        return state == .completed || state == .cancelled
    }

    /// returns true if the animation is currently paused
    public var isPaused : Bool {
        return state == .paused || state == .pausedInReverse
    }

    /// returns true if the animation is currently playing
    public var isPlaying : Bool {
        return state == .playing || state == .playingInReverse || state == .queued
    }

    /// returns true if the animation isPlaying, isPaused, or isCompleted.
    public var isQueued : Bool {
        return state != .notQueued
    }

    /// returns the inverted version of the animation ie. the 'EasingStyle' is inverted and the start and end values are swapped.
    public var inverse : Animation {
        return Animation(tween:tween.inverse)
    }

    /// Stops the animation and removes it from the 'AnimationManager'
    public func terminate() {
        if isQueued {
            state = .cancelled
        }
    }

    /// Pauses the animation
    public func pause() {
        if isPlaying {
            if state == .playingInReverse {
                state = .pausedInReverse
            } else {
                state = .paused
            }
        }
    }

    /// Plays the animation
    ///
    /// NB: Only plays if already added to 'AnimationManager'
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

    /// Restarts the animation to the initial value as specified in the 'Tween'.
    public func restart() {
        if isPlaying {
            state = .playing
        } else {
            state = .notQueued
        }
        self.elapsedTime = 0
    }

    /// Equivalence operator for two 'Animation's.
    static public func == (lhs:Animation, rhs:Animation) -> Bool {
        return lhs === rhs
    }
}
