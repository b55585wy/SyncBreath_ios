import Foundation

public enum BluetoothCommand {
    case breathingStart
    case breathingStop
    case breathingInhale
    case breathingHold
    case breathingExhale
    case setMotorIntensity(Double)
    case setPumpIntensity(Double)
    
    var data: Data {
        switch self {
        case .breathingStart:
            return Data([0x01])
        case .breathingStop:
            return Data([0x02])
        case .breathingInhale:
            return Data([0x03])
        case .breathingHold:
            return Data([0x04])
        case .breathingExhale:
            return Data([0x05])
        case .setMotorIntensity(let intensity):
            return Data([0x06, UInt8(intensity * 100)])
        case .setPumpIntensity(let intensity):
            return Data([0x07, UInt8(intensity * 100)])
        }
    }
}
