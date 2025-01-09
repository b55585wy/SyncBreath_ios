import SwiftUI
import Combine

class MeditationViewModel: ObservableObject {
    enum BreathPhase: String {
        case inhale = "吸气"
        case holdInhale = "屏气(吸气)"
        case exhale = "呼气"
        case holdExhale = "屏气(呼气)"
    }
    
    @Published var currentPhase: BreathPhase = .inhale
    @Published var progress: CGFloat = 0
    @Published var isBreathing = false
    
    // 呼吸时间设置
    @Published var inhaleTime: Double = 4.0
    @Published var exhaleTime: Double = 4.0
    @Published var holdTime: Double = 0.0
    
    private var timer: Timer?
    private var currentMode: MeditationType = .bambooGrove
    
    func startBreathing() {
        isBreathing = true
        startBreathCycle()
    }
    
    func pauseBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
    }
    
    func switchMode(_ mode: MeditationType) {
        currentMode = mode
        // 根据模式调整呼吸时间
        switch mode {
        case .bambooGrove:
            inhaleTime = 4.0
            exhaleTime = 4.0
            holdTime = 0.0
        case .cloudReturn:
            inhaleTime = 4.0
            exhaleTime = 6.0
            holdTime = 0.0
        case .starryNight:
            inhaleTime = 4.0
            exhaleTime = 4.0
            holdTime = 4.0
        case .mountainSpring:
            inhaleTime = 5.0
            exhaleTime = 5.0
            holdTime = 0.0
        case .zenMoment:
            inhaleTime = 6.0
            exhaleTime = 6.0
            holdTime = 2.0
        case .seasonCycle:
            inhaleTime = 4.0
            exhaleTime = 4.0
            holdTime = 0.0
        }
    }
    
    private func startBreathCycle() {
        let totalTime = inhaleTime + exhaleTime + (holdTime * 2)
        var elapsedTime: Double = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            elapsedTime += 0.01
            if elapsedTime >= totalTime {
                elapsedTime = 0
            }
            
            // 更新呼吸阶段和进度
            if elapsedTime < self.inhaleTime {
                self.currentPhase = .inhale
                self.progress = elapsedTime / self.inhaleTime
            } else if elapsedTime < (self.inhaleTime + self.holdTime) {
                self.currentPhase = .holdInhale
                self.progress = 1.0
            } else if elapsedTime < (self.inhaleTime + self.holdTime + self.exhaleTime) {
                self.currentPhase = .exhale
                self.progress = 1.0 - ((elapsedTime - self.inhaleTime - self.holdTime) / self.exhaleTime)
            } else {
                self.currentPhase = .holdExhale
                self.progress = 0.0
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
