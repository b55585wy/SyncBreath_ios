import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var volume: Float = 0.5
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var activeSound: String?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playSound(for mode: MeditationType, option: SoundOption) {
        guard let url = Bundle.main.url(forResource: option.fileName, withExtension: "mp3") else {
            print("Could not find sound file: \(option.fileName)")
            return
        }
        
        // Stop current sound if playing
        stopCurrentSound()
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Loop indefinitely
            player.volume = volume
            player.play()
            
            audioPlayers[option.fileName] = player
            activeSound = option.fileName
            isPlaying = true
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func stopCurrentSound() {
        if let currentSound = activeSound {
            audioPlayers[currentSound]?.stop()
            audioPlayers.removeValue(forKey: currentSound)
            activeSound = nil
            isPlaying = false
        }
    }
    
    func updateVolume() {
        if let currentSound = activeSound {
            audioPlayers[currentSound]?.volume = volume
        }
    }
    
    func fadeOut(completion: @escaping () -> Void) {
        guard let currentSound = activeSound,
              let player = audioPlayers[currentSound] else {
            completion()
            return
        }
        
        let fadeOutDuration: TimeInterval = 1.0
        let steps = 50
        let volumeStep = player.volume / Float(steps)
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: fadeOutDuration/TimeInterval(steps), repeats: true) { timer in
            currentStep += 1
            player.volume -= volumeStep
            
            if currentStep >= steps {
                timer.invalidate()
                self.stopCurrentSound()
                completion()
            }
        }
    }
    
    func crossFade(to newSound: SoundOption) {
        guard let url = Bundle.main.url(forResource: newSound.fileName, withExtension: "mp3") else {
            print("Could not find sound file: \(newSound.fileName)")
            return
        }
        
        do {
            // Prepare new player
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0
            newPlayer.play()
            
            // Store new player
            audioPlayers[newSound.fileName] = newPlayer
            
            // Fade out old sound while fading in new sound
            let fadeDuration: TimeInterval = 1.0
            let steps = 50
            let stepDuration = fadeDuration/TimeInterval(steps)
            
            if let currentSound = activeSound,
               let oldPlayer = audioPlayers[currentSound] {
                let oldVolumeStep = oldPlayer.volume / Float(steps)
                let newVolumeStep = volume / Float(steps)
                var currentStep = 0
                
                Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
                    currentStep += 1
                    oldPlayer.volume -= oldVolumeStep
                    newPlayer.volume += newVolumeStep
                    
                    if currentStep >= steps {
                        timer.invalidate()
                        oldPlayer.stop()
                        self.audioPlayers.removeValue(forKey: currentSound)
                    }
                }
            } else {
                // If no sound is currently playing, just fade in the new sound
                let newVolumeStep = volume / Float(steps)
                var currentStep = 0
                
                Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
                    currentStep += 1
                    newPlayer.volume += newVolumeStep
                    
                    if currentStep >= steps {
                        timer.invalidate()
                    }
                }
            }
            
            activeSound = newSound.fileName
            isPlaying = true
            
        } catch {
            print("Failed to prepare new sound: \(error)")
        }
    }
}
