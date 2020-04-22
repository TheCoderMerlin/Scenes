import Foundation

public enum EasingStyle {
    case linear
    
    // configurable exponential ease.
    case configureInPow(exponent:Double)
    case configureOutPow(exponent:Double)
    case configureInOutPow(exponent:Double)
    
    case inQuad
    case outQuad
    case inOutQuad
    
    case inCubic
    case outCubic
    case inOutCubic
    
    case inQuart
    case outQuart
    case inOutQuart
    
    case inQuint
    case outQuint
    case inOutQuint
    
    case inSine
    case outSine
    case inOutSine
    
    case inExponential
    case outExponential
    case inOutExponential
    
    case inBack
    case outBack
    case inOutBack
    
    case inCirc
    case outCirc
    case inOutCirc
    
    case inBounce
    case outBounce
    case inOutBounce
    
    case inElastic
    case outElastic
    case inOutElastic

    internal func apply(fraction:Double) -> Double {
        // ensure values at initial and ending positions are exact
        if fraction <= 0 {
            return 0
        } else if fraction >= 1 {
            return 1
        }

        switch self {
        case .linear:
            return fraction

        case .configureInPow(let exponent):
            return pow(fraction, exponent)
        case .configureOutPow(let exponent):
            return 1 - pow(1 - fraction, exponent)
        case .configureInOutPow(let exponent):
            return fraction < 0.5
              ? pow(fraction * 2, exponent) / 2
              : 1 - pow(2 - fraction * 2, exponent) / 2

        case .inQuad:
            return EasingStyle.configureInPow(exponent:2).apply(fraction:fraction)
        case .outQuad:
            return EasingStyle.configureOutPow(exponent:2).apply(fraction:fraction)
        case .inOutQuad:
            return EasingStyle.configureInOutPow(exponent:2).apply(fraction:fraction)

        case .inCubic:
            return EasingStyle.configureInPow(exponent:3).apply(fraction:fraction)
        case .outCubic:
            return EasingStyle.configureOutPow(exponent:3).apply(fraction:fraction)
        case .inOutCubic:
            return EasingStyle.configureInOutPow(exponent:3).apply(fraction:fraction)

        case .inQuart:
            return EasingStyle.configureInPow(exponent:4).apply(fraction:fraction)
        case .outQuart:
            return EasingStyle.configureOutPow(exponent:4).apply(fraction:fraction)
        case .inOutQuart:
            return EasingStyle.configureInOutPow(exponent:4).apply(fraction:fraction)

        case .inQuint:
            return EasingStyle.configureInPow(exponent:5).apply(fraction:fraction)
        case .outQuint:
            return EasingStyle.configureOutPow(exponent:5).apply(fraction:fraction)
        case .inOutQuint:
            return EasingStyle.configureInOutPow(exponent:5).apply(fraction:fraction)

        case .inSine:
            return 1 - cos(fraction * Double.pi / 2)
        case .outSine:
            return sin(fraction * Double.pi / 2)
        case .inOutSine:
            return (1 - cos(Double.pi * fraction)) / 2

        case .inExponential:
            return pow(1024, fraction - 1)
        case .outExponential:
            return 1 - pow(2, -10 * fraction)
        case .inOutExponential:
            return fraction < 0.5
              ? pow(1024, fraction * 2 - 1) / 2
              : (-pow(2, -10 * (fraction * 2 - 1)) + 2) / 2

        case .inBack:
            return pow(fraction, 2) * (2.7 * fraction - 1.7)
        case .outBack:
            return pow(fraction - 1, 2) * (2.7 * (fraction - 1) + 1.7) + 1
        case .inOutBack:
            return fraction < 0.5
              ? (pow(fraction * 2, 2) * (3.5925 * (fraction * 2) - 2.5925)) / 2
              : (pow(fraction * 2 - 2, 2) * (3.5925 * (fraction * 2 - 2) + 2.5925)) / 2 + 1

        case .inCirc:
            return 1 - sqrt(1 - pow(fraction, 2))
        case .outCirc:
            return sqrt(1 - pow(fraction - 1, 2))
        case .inOutCirc:
            return fraction < 0.5
              ? -(sqrt(1 - pow(fraction * 2, 2)) - 1) / 2
              : (sqrt(1 - pow(-fraction * 2 + 2, 2)) + 1) / 2

        case .inBounce:
            return 1 - EasingStyle.outBounce.apply(fraction:1-fraction)
        case .outBounce:
            if fraction < 1 / 2.75 {
                return 7.5625 * pow(fraction, 2)
            } else if fraction < 2 / 2.75 {
                return 7.5625 * pow(fraction - 1.5 / 2.75, 2) + 0.75
            } else if fraction < 2.5 / 2.75 {
                return 7.5625 * pow(fraction - 2.25 / 2.75, 2) + 0.9375
            } else {
                return 7.5625 * pow(fraction - 2.625 / 2.75, 2) + 0.984375
            }
        case .inOutBounce:
            return fraction < 0.5
              ? EasingStyle.inBounce.apply(fraction:fraction * 2) / 2
              : EasingStyle.outBounce.apply(fraction:fraction * 2 - 1) / 2 + 0.5

        case .inElastic:
            return -pow(2, 10 * fraction - 10) * sin((fraction * 10 - 10.75) * ((2 * Double.pi) / 3))
        case .outElastic:
            return pow(2, -10 * fraction) * sin((fraction * 10 - 0.75) * ((2 * Double.pi) / 3)) + 1
        case .inOutElastic:
            return fraction < 0.5
              ? -(pow(2, 20 * fraction - 10) * sin((20 * fraction - 11.125) * ((Double.pi * 2) / 4.5))) / 2
              : (pow(2, -20 * fraction + 10) * sin((20 * fraction - 11.125) * ((Double.pi * 2) / 4.5))) / 2 + 1
        }
    }
}
