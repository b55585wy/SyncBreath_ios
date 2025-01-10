import SwiftUI

struct BreathingPattern {
    var inhale: Int = 4    // 吸气时间（秒）
    var hold: Int = 4      // 屏息时间（秒）
    var exhale: Int = 4    // 呼气时间（秒）
    
    init(inhale: Int = 4, hold: Int = 4, exhale: Int = 4) {
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
    }
    
    var description: String {
        return "\(inhale)-\(hold)-\(exhale)"
    }
}

struct HardwareIntensity {
    var volume: Float = 0.8
    var vibration: Float = 1.0
}

struct BreathingSettings {
    var duration: Int = 15       // 练习时长（分钟）
    var breathingPattern: BreathingPattern = BreathingPattern()
    var hardwareIntensity: HardwareIntensity = HardwareIntensity()
    var enableSound: Bool = true
    var showProgress: Bool = true
    
    init(duration: Int = 15,
         breathingPattern: BreathingPattern = BreathingPattern(),
         hardwareIntensity: HardwareIntensity = HardwareIntensity(),
         enableSound: Bool = true,
         showProgress: Bool = true) {
        self.duration = duration
        self.breathingPattern = breathingPattern
        self.hardwareIntensity = hardwareIntensity
        self.enableSound = enableSound
        self.showProgress = showProgress
    }
}
