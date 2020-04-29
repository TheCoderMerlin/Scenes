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


/// A 'TweenSequence' is used to seguence different 'Tween's.

public class TweenSequence : InternalTweenProtocol, TweenProtocol {
    private var tweens = [InternalTweenProtocol]()

    /// The total amout of time taken, in seconds
    public let duration : Double

    public convenience init(delay:Double = 0, tweens:TweenProtocol...) {
        self.init(delay:delay, tweens:tweens)
    }

    /// Creates a new 'TweenSequence' from the specified parameters
    /// - Parameters:
    ///   - delay: the delay, in seconds, to add between each 'Tween'
    ///   - tweens: the tweens to sequence, one at a time
    public init(delay:Double = 0, tweens:[TweenProtocol]) {
        var duration = 0.0
        
        for (index, tween) in tweens.enumerated() {
            guard let tween = tween as? InternalTweenProtocol else {
                fatalError("tween doesn't conform to InternalTweenProtocol.")
            }
            
            if index == 0 || delay == 0 {
                self.tweens.append(tween)
                duration += tween.duration
            } else {
                self.tweens.append(DelayTween(duration:delay))
                self.tweens.append(tween)
                duration += (delay + tween.duration)
            }
        }
        
        self.duration = duration
    }

    internal init(tweens:[InternalTweenProtocol]) {
        var duration = 0.0
        
        for tween in tweens {
            self.tweens.append(tween)
            duration += tween.duration
        }
        
        self.duration = duration
    }

    internal var inverse : InternalTweenProtocol {
        var invertedTweens = [InternalTweenProtocol]()
        for tween in tweens {
            invertedTweens.append(tween.inverse)
        }
        invertedTweens.reverse()
        return TweenSequence(tweens:invertedTweens)
    }

    internal func update(percent:Double) {
        let timeElapsed = duration * percent
        var timeToCurrentTween = 0.0
        if let tween = findCurrentTween(timeElapsed:timeElapsed, timeToCurrentTween:&timeToCurrentTween) {
            let tweenTimeElapsed = timeElapsed - timeToCurrentTween
            tween.update(percent:tweenTimeElapsed/tween.duration)
        }
    }

    private func findCurrentTween(timeElapsed:Double, timeToCurrentTween:inout Double) -> InternalTweenProtocol? {
        for tween in tweens {
            if timeToCurrentTween + tween.duration < timeElapsed {
                timeToCurrentTween += tween.duration
            } else {
                return tween
            }
        }
        return nil
    }
}
