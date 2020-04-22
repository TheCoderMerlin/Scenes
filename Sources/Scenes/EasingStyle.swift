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

    // depending on EasingStyle, generate a new percent value from given percent value
    internal func apply(percent:Double) -> Double {
        // ensure values at initial and ending positions are exact
        if percent <= 0 {
            return 0
        } else if percent >= 1 {
            return 1
        }

        switch self {
        case .linear:
            return percent

        case .configureInPow(let exponent):
            return pow(percent, exponent)
        case .configureOutPow(let exponent):
            return 1 - pow(1 - percent, exponent)
        case .configureInOutPow(let exponent):
            return percent < 0.5
              ? pow(percent * 2, exponent) / 2
              : 1 - pow(2 - percent * 2, exponent) / 2

        case .inQuad:
            return EasingStyle.configureInPow(exponent:2).apply(percent:percent)
        case .outQuad:
            return EasingStyle.configureOutPow(exponent:2).apply(percent:percent)
        case .inOutQuad:
            return EasingStyle.configureInOutPow(exponent:2).apply(percent:percent)

        case .inCubic:
            return EasingStyle.configureInPow(exponent:3).apply(percent:percent)
        case .outCubic:
            return EasingStyle.configureOutPow(exponent:3).apply(percent:percent)
        case .inOutCubic:
            return EasingStyle.configureInOutPow(exponent:3).apply(percent:percent)

        case .inQuart:
            return EasingStyle.configureInPow(exponent:4).apply(percent:percent)
        case .outQuart:
            return EasingStyle.configureOutPow(exponent:4).apply(percent:percent)
        case .inOutQuart:
            return EasingStyle.configureInOutPow(exponent:4).apply(percent:percent)

        case .inQuint:
            return EasingStyle.configureInPow(exponent:5).apply(percent:percent)
        case .outQuint:
            return EasingStyle.configureOutPow(exponent:5).apply(percent:percent)
        case .inOutQuint:
            return EasingStyle.configureInOutPow(exponent:5).apply(percent:percent)

        case .inSine:
            return 1 - cos(percent * Double.pi / 2)
        case .outSine:
            return sin(percent * Double.pi / 2)
        case .inOutSine:
            return (1 - cos(Double.pi * percent)) / 2

        case .inExponential:
            return pow(1024, percent - 1)
        case .outExponential:
            return 1 - pow(2, -10 * percent)
        case .inOutExponential:
            return percent < 0.5
              ? pow(1024, percent * 2 - 1) / 2
              : (-pow(2, -10 * (percent * 2 - 1)) + 2) / 2

        case .inBack:
            return pow(percent, 2) * (2.7 * percent - 1.7)
        case .outBack:
            return pow(percent - 1, 2) * (2.7 * (percent - 1) + 1.7) + 1
        case .inOutBack:
            return percent < 0.5
              ? (pow(percent * 2, 2) * (3.5925 * (percent * 2) - 2.5925)) / 2
              : (pow(percent * 2 - 2, 2) * (3.5925 * (percent * 2 - 2) + 2.5925)) / 2 + 1

        case .inCirc:
            return 1 - sqrt(1 - pow(percent, 2))
        case .outCirc:
            return sqrt(1 - pow(percent - 1, 2))
        case .inOutCirc:
            return percent < 0.5
              ? -(sqrt(1 - pow(percent * 2, 2)) - 1) / 2
              : (sqrt(1 - pow(-percent * 2 + 2, 2)) + 1) / 2

        case .inBounce:
            return 1 - EasingStyle.outBounce.apply(percent:1-percent)
        case .outBounce:
            if percent < 1 / 2.75 {
                return 7.5625 * pow(percent, 2)
            } else if percent < 2 / 2.75 {
                return 7.5625 * pow(percent - 1.5 / 2.75, 2) + 0.75
            } else if percent < 2.5 / 2.75 {
                return 7.5625 * pow(percent - 2.25 / 2.75, 2) + 0.9375
            } else {
                return 7.5625 * pow(percent - 2.625 / 2.75, 2) + 0.984375
            }
        case .inOutBounce:
            return percent < 0.5
              ? EasingStyle.inBounce.apply(percent:percent * 2) / 2
              : EasingStyle.outBounce.apply(percent:percent * 2 - 1) / 2 + 0.5

        case .inElastic:
            return -pow(2, 10 * percent - 10) * sin((percent * 10 - 10.75) * ((2 * Double.pi) / 3))
        case .outElastic:
            return pow(2, -10 * percent) * sin((percent * 10 - 0.75) * ((2 * Double.pi) / 3)) + 1
        case .inOutElastic:
            return percent < 0.5
              ? -(pow(2, 20 * percent - 10) * sin((20 * percent - 11.125) * ((Double.pi * 2) / 4.5))) / 2
              : (pow(2, -20 * percent + 10) * sin((20 * percent - 11.125) * ((Double.pi * 2) / 4.5))) / 2 + 1
        }
    }
}
