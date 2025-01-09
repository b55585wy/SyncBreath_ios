import SwiftUI

struct AppTheme {
    static let colors = ThemeColors()
    static let fonts = ThemeFonts()
    static let animations = ThemeAnimations()
}

struct ThemeColors {
    // 竹林晨露
    let bambooGradient = [
        Color("BambooLight"),
        Color("BambooDark")
    ]
    
    // 归云息
    let cloudGradient = [
        Color("CloudLight"),
        Color("CloudDark")
    ]
    
    // 星河入梦
    let starryGradient = [
        Color("StarryLight"),
        Color("StarryDark")
    ]
    
    // 山泉呼吸
    let mountainGradient = [
        Color("MountainLight"),
        Color("MountainDark")
    ]
    
    // 禅心一刻
    let zenGradient = [
        Color("ZenLight"),
        Color("ZenDark")
    ]
    
    // 四季轮转
    struct SeasonColors {
        let spring = [Color("SpringLight"), Color("SpringDark")]
        let summer = [Color("SummerLight"), Color("SummerDark")]
        let autumn = [Color("AutumnLight"), Color("AutumnDark")]
        let winter = [Color("WinterLight"), Color("WinterDark")]
        
        func colorsForMonth(_ month: Int) -> [Color] {
            switch month {
            case 3...5:  // Spring (3-5月)
                return spring
            case 6...8:  // Summer (6-8月)
                return summer
            case 9...11: // Autumn (9-11月)
                return autumn
            default:     // Winter (12-2月)
                return winter
            }
        }
        
        func currentSeasonColors() -> [Color] {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: Date())
            return colorsForMonth(month)
        }
    }
    
    let seasonColors = SeasonColors()
}

struct ThemeFonts {
    // 使用系统字体模拟书法风格
    static let titleFont = Font.system(.largeTitle, design: .serif)
    static let quoteFont = Font.system(.title, design: .serif)
    static let bodyFont = Font.system(.body, design: .serif)
}

struct ThemeAnimations {
    // 动画时长配置
    static let breatheDuration: Double = 4.0
    static let transitionDuration: Double = 0.8
    
    // 动画曲线
    static let breatheEasing = Animation.easeInOut(duration: breatheDuration)
    static let transitionEasing = Animation.easeInOut(duration: transitionDuration)
}
