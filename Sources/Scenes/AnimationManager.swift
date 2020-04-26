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


/// The 'AnimationManager' handles the queuing and updating of 'Animation's.

public class AnimationManager {
    private weak var director : Director?
    
    private var animations = [Animation]()
    private var animationsPendingRemoval = [Animation]()
    
    init(director:Director) {
        self.director = director
    }

    // called anytime we need to remove an animation from manager
    internal func remove(animation:Animation) {
        animation.restart()
        guard let index = animations.firstIndex(of:animation) else {
            fatalError("Animation queued for removal does not exist.")
        }
        animations.remove(at:index)
    }

    // updates animations every frame
    internal func updateFrame() {
        // remove all completed animations
        animationsPendingRemoval.forEach {
            remove(animation:$0)
        }
        animationsPendingRemoval.removeAll()
        
        // if an animation is completed, append it to removal list, otherwise update it
        animations.forEach {
            $0.updateFrame(frameRate:1/Double(director!.framesPerSecond()))
            if $0.isCompleted {
                animationsPendingRemoval.append($0)
            }
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    /// Allows for you to retrieve an altered percent represented by an 'EasingStyle'
    /// - Parameters:
    ///   - ease: The 'EasingStyle' to retrieve an altered percent from
    ///   - percent: The percent to apply to the ease
    /// - Returns: A new percent as altered by the ease
    public func getValue(ease:EasingStyle, percent:Double) -> Double {
        return ease.apply(percent:percent)
    }

    /// Adds a new 'Animation' to the 'AnimationManager' for updating
    /// - Parameters:
    ///   - animation: The 'Animation' to add
    ///   - autoPlay: Whether or not to automatically begin playing the animation upon registering it
    public func run(animation:Animation, autoPlay:Bool = true) {
        if animation.isCompleted {
            animation.state = .notQueued
        }
        animations.append(animation)
        if autoPlay {
            animation.play()
        }
    }

    /// Calls the terminate() function on all registered 'Animation's
    public func terminateAll() {
        animations.forEach {
            $0.terminate()
        }
    }

    /// Calls the pause() function on all registered 'Animation's
    public func pauseAll() {
        animations.forEach {
            $0.pause()
        }
    }

    /// Calls the play() function on all registered 'Animation's
    public func playAll() {
        animations.forEach {
            $0.play()
        }
    }

    /// Calls the restart() function on all registered 'Animation's
    public func restartAll() {
        animations.forEach {
            $0.restart()
        }
    }
}
