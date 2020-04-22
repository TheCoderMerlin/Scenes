public class AnimationManager {
    private weak var director : Director?
    
    private var animations = [Animation]()
    private var animationsPendingRemoval = [Animation]()

    init(director:Director) {
        self.director = director
    }

    internal func remove(animation:Animation) {
        guard let index = animations.firstIndex(of:animation) else {
            fatalError("Animation queued for removal does not exist.")
        }
        animations.remove(at:index)
    }
    
    internal func updateFrame() {
        // remove all completed animations
        animationsPendingRemoval.forEach {
            remove(animation:$0)
        }
        animationsPendingRemoval.removeAll()

        // if an animation is completed, append it to removal list, otherwise update it
        animations.forEach {
            $0.isCompleted
              ? animationsPendingRemoval.append($0)
              : $0.updateFrame(frameRate:1/Double(director!.framesPerSecond()))
        }
    }

    // ********************************************************************************
    // API FOLLOWS
    // ********************************************************************************

    public func runAnimation(animation:Animation, autoPlay:Bool = true) {
        animations.append(animation)
        if autoPlay {
            animation.play()
        }
    }

    public func getValue(ease:EasingStyle, fraction:Double) -> Double {
        return ease.apply(fraction:fraction)
    }

    public func terminateAll() {
        animations.forEach {
            $0.terminate()
            remove(animation:$0)
        }
    }

    public func pauseAll() {
        animations.forEach {
            $0.pause()
        }
    }

    public func playAll() {
        animations.forEach {
            $0.play()
        }
    }
}
