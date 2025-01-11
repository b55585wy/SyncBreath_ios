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
    }
}
