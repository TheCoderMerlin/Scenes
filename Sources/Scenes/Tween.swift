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


/// A 'Tween' is used to create an 'Animation' for animating various elements.
///
/// NB: update is a trailing [closure](https://docs.swift.org/swift-book/LanguageGuide/Closures.html) and as such offers many initialization formats.
/// For example, both of the following statements work:
///
/// ~~~
/// let tween = Tween(from:Point(), to:Point(x:100, y:100), update: {self.rectangle.rect.topLeft = $0})
/// ~~~
///
/// OR
///
/// ~~~
/// let tween = Tween(from:Point(), to:Point(x:100, y:100)) {
///     self.rectangle.rect.topLeft = $0
/// }
/// ~~~

public class Tween<TweenElement: Tweenable> : InternalTweenProtocol, TweenProtocol {
    private let startValue : TweenElement
    private let endValue : TweenElement

    /// The amount of time taken, in seconds, from start to end
    public let duration : Double
    /// The 'EasingStyle' applied
    public let ease : EasingStyle

    var updateHandler : (TweenElement) -> () = {_ in}

    /// Creates a new 'Tween' from the specified parameters
    /// - Parameters:
    ///   - from: The starting value
    ///   - to: The ending value
    ///   - duration: The amount of time to take
    ///   - ease: The 'EasingStyle' to apply
    ///   - update: The value to update
    public init(from:TweenElement, to:TweenElement, duration:Double = 1, ease:EasingStyle = .linear, update:@escaping (TweenElement) -> ()) {
        self.startValue = from
        self.endValue = to
        self.duration = duration
        self.ease = ease
        self.updateHandler = update
    }

    /// Creates a new 'Tween' from the specified parameters
    /// - Parameters:
    ///   - from: The starting value
    ///   - to: The ending value
    ///   - speed: The speed to animate the element at (in pixels per second)
    ///   - ease: The 'EasingStyle' to apply
    ///   - update: The value to update
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

    internal func inverse() -> InternalTweenProtocol {
        return Tween(from:endValue, to:startValue, duration:duration, ease:ease.inverse, update:updateHandler)
    }
}
