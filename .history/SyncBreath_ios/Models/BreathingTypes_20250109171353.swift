import Foundation

// 呼吸类型枚举
enum BreathingType: String, CaseIterable, Codable {
    case box = "专注呼吸"
    case relaxed = "放松呼吸"
    case energizing = "能量呼吸"
    
    var pattern: BreathingPattern {
        switch self {
        case .box: return BreathingPattern(inhale: 4, hold1: 4, exhale: 4, hold2: 4)
        case .relaxed: return BreathingPattern(inhale: 4, hold1: 0, exhale: 6, hold2: 0)
        case .energizing: return BreathingPattern(inhale: 6, hold1: 0, exhale: 4, hold2: 0)
        }
    }
}

// 硬件强度设置
struct HardwareIntensity: Codable {
    var volume: Float
    var vibration: Float
    
    init(volume: Float = 0.5, vibration: Float = 0.0) {
        self.volume = volume
        self.vibration = vibration
    }
}

// 呼吸设置
struct BreathingSettings: Codable {
    var duration: Int
    var enableSound: Bool
    var showProgress: Bool
    var hardwareIntensity: HardwareIntensity
    var breathingType: BreathingType
    
    init(
        duration: Int = 5,
        enableSound: Bool = true,
        showProgress: Bool = true,
        hardwareIntensity: HardwareIntensity = HardwareIntensity(),
        breathingType: BreathingType = .box
    ) {
        self.duration = duration
        self.enableSound = enableSound
        self.showProgress = showProgress
        self.hardwareIntensity = hardwareIntensity
        self.breathingType = breathingType
    }
}

// 呼吸模式
struct BreathingPattern: Codable {
    let inhale: Int
    let hold1: Int
    let exhale: Int
    let hold2: Int
}
