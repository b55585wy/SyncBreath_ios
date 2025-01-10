import SwiftUI
import Foundation

// Remove duplicate type definitions and use shared types
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
    
    var defaultPattern: BreathingPattern {
        switch self {
        case .bambooGrove:
            return BreathingPattern(inhale: 4, hold: 4, exhale: 4)
        case .cloudReturn:
            return BreathingPattern(inhale: 6, hold: 3, exhale: 6)
        case .starryNight:
            return BreathingPattern(inhale: 4, hold: 7, exhale: 8)
        case .mountainSpring:
            return BreathingPattern(inhale: 4, hold: 4, exhale: 6)
        case .zenMoment:
            return BreathingPattern(inhale: 5, hold: 5, exhale: 5)
        case .seasonCycle:
            return BreathingPattern(inhale: 4, hold: 4, exhale: 4)
        }
    }
}

struct MeditationMode: Identifiable {
    let id = UUID()
    let type: MeditationType
    var customPattern: BreathingPattern?
    
    var breathingPattern: BreathingPattern {
        customPattern ?? type.defaultPattern
    }
    
    var title: String {
        type.rawValue
    }
    
    var description: String {
        type.description
    }
}

struct SoundOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fileName: String
    
    static func == (lhs: SoundOption, rhs: SoundOption) -> Bool {
        lhs.fileName == rhs.fileName && lhs.name == rhs.name
    }
    
    static let options: [MeditationType: [SoundOption]] = [
        .bambooGrove: [
            SoundOption(name: "竹林清音", fileName: "bamboo_grove"),
            SoundOption(name: "晨风细语", fileName: "morning_breeze"),
            SoundOption(name: "露珠滴落", fileName: "dewdrops")
        ],
        .cloudReturn: [
            SoundOption(name: "山水之声", fileName: "mountain_stream"),
            SoundOption(name: "云雾缭绕", fileName: "misty_clouds")
        ],
        .starryNight: [
            SoundOption(name: "星空微风", fileName: "night_wind"),
            SoundOption(name: "银河流音", fileName: "galaxy_flow")
        ],
        .mountainSpring: [
            SoundOption(name: "溪水潺潺", fileName: "stream_flow"),
            SoundOption(name: "山泉叮咚", fileName: "spring_water")
        ],
        .zenMoment: [
            SoundOption(name: "木鱼声", fileName: "wooden_fish"),
            SoundOption(name: "禅钟声", fileName: "zen_bell")
        ],
        .seasonCycle: [
            SoundOption(name: "自然交响", fileName: "nature_symphony"),
            SoundOption(name: "四季轮转", fileName: "season_cycle")
        ]
    ]
}
