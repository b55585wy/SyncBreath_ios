import SwiftUI
import Combine
import CoreBluetooth

class MeditationViewModel: ObservableObject {
    // Published properties
    @Published var currentMode: MeditationMode
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var progress: Double = 0
    @Published var isBreathing = false
    @Published var currentBreathCount = 0
    @Published var selectedSound: SoundOption?
    
    // Timer related
    private var breathingTimer: Timer?
    private var phaseTimer: Timer?
    private var currentPhaseStartTime: Date?
    
    // Current pattern timing
    private let bluetoothManager = BluetoothManager.shared
    
    var currentPattern: BreathingPattern {
        currentMode.breathingPattern
    }
    
    init(mode: MeditationType = .bambooGrove) {
        self.currentMode = MeditationMode(type: mode)
    }
    
    func startBreathing() {
        isBreathing = true
        currentBreathCount = 0
        progress = 0
        startBreathCycle()
        
        if bluetoothManager.deviceStatus.isConnected {
            configureHardware()
            bluetoothManager.sendCommand(.breathingStart)
        }
    }
    
    func pauseBreathing() {
        isBreathing = false
        breathingTimer?.invalidate()
        breathingTimer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
        
        if bluetoothManager.deviceStatus.isConnected {
            bluetoothManager.sendCommand(.breathingStop)
        }
    }
    
    private func startBreathCycle() {
        moveToNextPhase()
        startPhaseTimer()
    }
    
    private func startPhaseTimer() {
        currentPhaseStartTime = Date()
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func getCurrentPhaseDuration() -> Double {
        switch currentPhase {
        case .inhale: return Double(currentPattern.inhale)
        case .hold: return Double(currentPattern.hold)
        case .exhale: return Double(currentPattern.exhale)
        }
    }
    
    private func updateProgress() {
        guard let startTime = currentPhaseStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let phaseDuration = getCurrentPhaseDuration()
        
        if elapsed >= phaseDuration {
            moveToNextPhase()
        } else {
            progress = elapsed / phaseDuration
        }
    }
    
    private func moveToNextPhase() {
        progress = 0
        switch currentPhase {
        case .inhale:
            currentPhase = currentPattern.hold > 0 ? .hold : .exhale
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .inhale
            currentBreathCount += 1
        }
        currentPhaseStartTime = Date()
        
        if bluetoothManager.deviceStatus.isConnected {
            switch currentPhase {
            case .inhale:
                bluetoothManager.sendCommand(.breathingInhale)
            case .hold:
                bluetoothManager.sendCommand(.breathingHold)
            case .exhale:
                bluetoothManager.sendCommand(.breathingExhale)
            }
        }
    }
    
    private func configureHardware() {
        // Configure hardware settings based on current mode
        let settings = BreathingSettings()
        bluetoothManager.sendCommand(.setMotorIntensity(settings.hardwareIntensity.motor))
        bluetoothManager.sendCommand(.setPumpIntensity(settings.hardwareIntensity.pump))
    }
    
    deinit {
        pauseBreathing()
    }
}
