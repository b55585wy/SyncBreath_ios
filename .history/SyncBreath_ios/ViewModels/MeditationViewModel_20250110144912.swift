import SwiftUI
import Combine

class MeditationViewModel: ObservableObject {
    enum BreathPhase: String {
        case inhale = "吸气"
        case hold = "屏气"
        case exhale = "呼气"
    }
    
    // Published properties
    @Published var currentMode: MeditationMode
    @Published var isBreathing = false
    @Published var currentPhase: BreathPhase = .inhale
    @Published var progress: Double = 0
    @Published var selectedSound: SoundOption?
    @Published var duration: Int = 15  // 默认15分钟
    
    // 存储每个模式选择的音效
    private var soundSelections: [MeditationType: SoundOption] = [:]
    
    // Timer related
    private var breathTimer: Timer?
    private var phaseTimer: Timer?
    
    // Current pattern timing
    private var currentPattern: BreathPattern {
        currentMode.breathPattern
    }
    
    init(mode: MeditationType = .bambooGrove) {
        self.currentMode = MeditationMode(type: mode)
        // 设置默认音效
        let defaultSound = SoundOption.bambooGroveOptions.first
        selectedSound = defaultSound
        soundSelections[mode] = defaultSound
    }
    
    func startBreathing() {
        print("startBreathing called")
        isBreathing = true
        startBreathCycle()
    }
    
    func pauseBreathing() {
        isBreathing = false
        breathTimer?.invalidate()
        phaseTimer?.invalidate()
    }
    
    func switchMode(_ type: MeditationType) {
        pauseBreathing()
        currentMode = MeditationMode(type: type)
        progress = 0
        currentPhase = .inhale
        
        // 使用已保存的音效选择，如果没有则使用默认值
        if let savedSound = soundSelections[type] {
            selectedSound = savedSound
        } else {
            let defaultSound: SoundOption
            switch type {
            case .bambooGrove:
                defaultSound = SoundOption.bambooGroveOptions.first!
            case .cloudReturn:
                defaultSound = SoundOption.cloudReturnOptions.first!
            case .starryNight:
                defaultSound = SoundOption.starryNightOptions.first!
            case .mountainSpring:
                defaultSound = SoundOption.mountainSpringOptions.first!
            case .zenMoment:
                defaultSound = SoundOption.zenMomentOptions.first!
            case .seasonCycle:
                defaultSound = SoundOption.seasonOptions.first!
            }
            selectedSound = defaultSound
            soundSelections[type] = defaultSound
        }
    }
    
    // 更新音效选择
    func updateSoundSelection(_ sound: SoundOption) {
        selectedSound = sound
        soundSelections[currentMode.type] = sound
    }
    
    private func startBreathCycle() {
        print("startBreathCycle called")  // Log cycle start
        currentPhase = .inhale
        updatePhaseTimer()
        
        // Update progress continuously
        breathTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updatePhaseTimer() {
        let duration: TimeInterval
        
        switch currentPhase {
        case .inhale:
            duration = TimeInterval(currentPattern.inhale)
        case .hold:
            duration = TimeInterval(currentPattern.hold)
        case .exhale:
            duration = TimeInterval(currentPattern.exhale)
        }
        
        print("updatePhaseTimer: setting timer for \(duration) seconds in phase \(currentPhase)")  // Log timer setup
        
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        print("moveToNextPhase called: current phase = \(currentPhase)")  // Log phase transition
        
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .inhale
        }
        
        print("moveToNextPhase: new phase = \(currentPhase)")  // Log new phase
        
        if isBreathing {
            updatePhaseTimer()
        }
    }
    
    private func updateProgress() {
        let totalDuration = Double(currentPattern.inhale + currentPattern.hold + currentPattern.exhale)
        let increment = 0.1 / totalDuration
        progress += increment
        
        if progress >= 1.0 {
            progress = 0.0
            print("Progress reset to 0")  // Log progress reset
        }
    }
    
    func updateBreathingSettings(duration: Int, pattern: BreathPattern) {
        print("Updating breathing settings: duration=\(duration), pattern=\(pattern.inhale)-\(pattern.hold)-\(pattern.exhale)")
        self.duration = duration
        self.currentMode.customBreathPattern = pattern
    }
    
    deinit {
        breathTimer?.invalidate()
        phaseTimer?.invalidate()
    }
}
