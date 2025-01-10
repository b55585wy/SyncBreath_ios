import SwiftUI

enum MeditationType: String, CaseIterable {
    case bambooGrove = "竹林晨露"    // Focus mode
    case cloudReturn = "归云息"      // Deep relaxation
    case starryNight = "星河入梦"    // Sleep mode
    case mountainSpring = "山泉呼吸"  // Stress relief
    case zenMoment = "禅心一刻"      // Meditation
    case seasonCycle = "四季轮转"    // Custom mode
    
    var description: String {
        switch self {
        case .bambooGrove:
            return "静心如竹，守得云开见月明"
        case .cloudReturn:
            return "随云归去，放下尘心"
        case .starryNight:
            return "繁星入怀，好梦自来"
        case .mountainSpring:
            return "心若山泉，静水流深"
        case .zenMoment:
            return "一念静心，万法归一"
        case .seasonCycle:
            return "随心而动，应时而变"
        }
    }
    
    var breathPattern: BreathPattern {
        switch self {
        case .bambooGrove:
            return BreathPattern(inhale: 4, hold: 4, exhale: 4)
        case .cloudReturn:
            return BreathPattern(inhale: 6, hold: 3, exhale: 6)
        case .starryNight:
            return BreathPattern(inhale: 4, hold: 7, exhale: 8)
        case .mountainSpring:
            return BreathPattern(inhale: 4, hold: 4, exhale: 6)
        case .zenMoment:
            return BreathPattern(inhale: 5, hold: 5, exhale: 5)
        case .seasonCycle:
            return BreathPattern(inhale: 4, hold: 4, exhale: 4) // Default pattern
        }
    }
    
    var defaultBreathPattern: BreathPattern {
        switch self {
        case .bambooGrove:
            return BreathPattern(inhale: 4, hold: 4, exhale: 4)
        case .cloudReturn:
            return BreathPattern(inhale: 6, hold: 3, exhale: 6)
        case .starryNight:
            return BreathPattern(inhale: 4, hold: 7, exhale: 8)
        case .mountainSpring:
            return BreathPattern(inhale: 4, hold: 4, exhale: 6)
        case .zenMoment:
            return BreathPattern(inhale: 5, hold: 5, exhale: 5)
        case .seasonCycle:
            return BreathPattern(inhale: 4, hold: 4, exhale: 4)
        }
    }
}

struct BreathPattern {
    let inhale: Int
    let hold: Int
    let exhale: Int
}

struct MeditationMode: Identifiable {
    let id = UUID()
    let type: MeditationType
    var customBreathPattern: BreathPattern?
    
    var breathPattern: BreathPattern {
        customBreathPattern ?? type.breathPattern
    }
    
    var title: String {
        type.rawValue
    }
    
    var description: String {
        type.description
    }
    
    init(type: MeditationType) {
        self.type = type
        self.breathPattern = type.defaultBreathPattern
    }
}

struct SoundOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fileName: String
    
    static func == (lhs: SoundOption, rhs: SoundOption) -> Bool {
        lhs.fileName == rhs.fileName && lhs.name == rhs.name
    }
    
    static let bambooGroveOptions = [
        SoundOption(name: "竹林清音", fileName: "bamboo_grove"),
        SoundOption(name: "晨风细语", fileName: "morning_breeze"),
        SoundOption(name: "露珠滴落", fileName: "dewdrops")
    ]
    
    static let cloudReturnOptions = [
        SoundOption(name: "山水之声", fileName: "mountain_stream"),
        SoundOption(name: "云雾缭绕", fileName: "misty_clouds")
    ]
    
    static let starryNightOptions = [
        SoundOption(name: "星空微风", fileName: "night_wind"),
        SoundOption(name: "银河流音", fileName: "galaxy_flow")
    ]
    
    static let mountainSpringOptions = [
        SoundOption(name: "溪水潺潺", fileName: "stream_flow"),
        SoundOption(name: "山泉叮咚", fileName: "spring_water")
    ]
    
    static let zenMomentOptions = [
        SoundOption(name: "木鱼声", fileName: "wooden_fish"),
        SoundOption(name: "禅钟声", fileName: "zen_bell")
    ]
    
    static let seasonOptions = [
        SoundOption(name: "春日鸟语", fileName: "spring_birds"),
        SoundOption(name: "夏夜蝉鸣", fileName: "summer_cicadas"),
        SoundOption(name: "秋风落叶", fileName: "autumn_leaves"),
        SoundOption(name: "冬日暖阳", fileName: "winter_sun")
    ]
}
