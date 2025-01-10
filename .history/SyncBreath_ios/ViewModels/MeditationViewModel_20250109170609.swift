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
    
    // Timer related
    private var breathTimer: Timer?
    private var phaseTimer: Timer?
    
    // Current pattern timing
    private var currentPattern: BreathPattern {
        currentMode.breathPattern
    }
    
    init(mode: MeditationType = .bambooGrove) {
        self.currentMode = MeditationMode(type: mode)
    }
    
    func startBreathing() {
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
    }
    
    private func startBreathCycle() {
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
        
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .inhale
        }
        
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
        }
    }
    
    deinit {
        breathTimer?.invalidate()
        phaseTimer?.invalidate()
    }
}

struct MeditationSettings {
    // 振动反馈
    var enableVibration: Bool = true
    
    // 声音设置
    var enableSound: Bool = true
    var volume: Double = 0.8
    
    // 显示设置
    var showTimer: Bool = true
    var showPhaseText: Bool = true
    
    // 通知设置
    var enableReminders: Bool = false
    var reminderTime: Date = Date()
    
    // 主题设置
    var darkMode: Bool = false
    var accentColor: Color = .blue
}
