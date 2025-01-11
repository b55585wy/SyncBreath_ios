import Foundation

struct SoundOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fileName: String
    
    static func == (lhs: SoundOption, rhs: SoundOption) -> Bool {
        lhs.id == rhs.id
    }
}

extension SoundOption {
    // 竹林晨露音效
    static let bambooGroveOptions: [SoundOption] = [
        SoundOption(name: "晨露滴落", fileName: "bamboo_morning"),
        SoundOption(name: "竹林微风", fileName: "bamboo_wind"),
        SoundOption(name: "鸟鸣清晨", fileName: "bamboo_birds")
    ]
    
    // 归云息音效
    static let cloudReturnOptions: [SoundOption] = [
        SoundOption(name: "轻云飘荡", fileName: "cloud_float"),
        SoundOption(name: "山间流水", fileName: "cloud_stream"),
        SoundOption(name: "云雾缭绕", fileName: "cloud_mist")
    ]
    
    // 星河入梦音效
    static let starryNightOptions: [SoundOption] = [
        SoundOption(name: "星空低语", fileName: "starry_whisper"),
        SoundOption(name: "银河流转", fileName: "starry_galaxy"),
        SoundOption(name: "夜风轻抚", fileName: "starry_breeze")
    ]
    
    // 山泉音效
    static let mountainSpringOptions: [SoundOption] = [
        SoundOption(name: "泉水叮咚", fileName: "spring_water"),
        SoundOption(name: "山风呢喃", fileName: "spring_wind"),
        SoundOption(name: "溪流潺潺", fileName: "spring_stream")
    ]
    
    // 禅意音效
    static let zenMomentOptions: [SoundOption] = [
        SoundOption(name: "木鱼声声", fileName: "zen_woodfish"),
        SoundOption(name: "钟声悠远", fileName: "zen_bell"),
        SoundOption(name: "禅院清音", fileName: "zen_temple")
    ]
    
    // 四季轮转音效
    static let seasonOptions: [SoundOption] = [
        SoundOption(name: "春日和风", fileName: "season_spring"),
        SoundOption(name: "夏日蝉鸣", fileName: "season_summer"),
        SoundOption(name: "秋日落叶", fileName: "season_autumn"),
        SoundOption(name: "冬日飘雪", fileName: "season_winter")
    ]
} 