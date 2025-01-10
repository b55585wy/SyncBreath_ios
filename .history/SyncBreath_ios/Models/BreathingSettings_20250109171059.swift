import Foundation

struct BreathingSettings {
    var duration: Int = 15       // 练习时长（分钟）
    var enableSound: Bool = true
    var showProgress: Bool = true
    var hardwareIntensity: HardwareIntensity = HardwareIntensity()
}

struct HardwareIntensity {
    var volume: Float = 0.8
    var vibration: Float = 1.0
} 