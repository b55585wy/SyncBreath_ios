import Foundation
//
//enum BreathingPhase: String {
//    case inhale = "吸气"
//    case hold = "屏息"
//    case exhale = "呼气"
//}

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
    var motor: Double = 0.7  // 电机强度 (0.0-1.0)
    var pump: Double = 0.6   // 气泵强度 (0.0-1.0)
    
    init(motor: Double = 0.7, pump: Double = 0.6) {
        self.motor = motor
        self.pump = pump
    }
}

struct BreathingSettings {
    var duration: Int = 15       // 练习时长（分钟）
    var breathingPattern: BreathingPattern = BreathingPattern()
    var hardwareIntensity: HardwareIntensity = HardwareIntensity()
    
    init(duration: Int = 15,
         breathingPattern: BreathingPattern = BreathingPattern(),
         hardwareIntensity: HardwareIntensity = HardwareIntensity()) {
        self.duration = duration
        self.breathingPattern = breathingPattern
        self.hardwareIntensity = hardwareIntensity
    }
}
