import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    // 音频播放器
    private var audioPlayer: AVAudioPlayer?
    private var breathingPlayer: AVAudioPlayer?
    
    // 状态
    @Published var volume: Double = 0.5
    @Published var isMuted: Bool = false
    @Published var isPlaying: Bool = false
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 音频控制
    func playSound(for meditationType: MeditationType, option: SoundOption) {
        guard let url = Bundle.main.url(forResource: option.fileName, withExtension: "mp3") else {
            print("找不到音频文件: \(option.fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 循环播放
            audioPlayer?.volume = Float(volume)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("音频播放失败: \(error.localizedDescription)")
        }
    }
    
    func playBreathingSound(inhale: Bool) {
        let fileName = inhale ? "inhale" : "exhale"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("找不到呼吸音效文件")
            return
        }
        
        do {
            breathingPlayer = try AVAudioPlayer(contentsOf: url)
            breathingPlayer?.volume = Float(volume)
            breathingPlayer?.play()
        } catch {
            print("呼吸音效播放失败: \(error.localizedDescription)")
        }
    }
    
    func stopBreathingSound() {
        breathingPlayer?.stop()
        breathingPlayer = nil
    }
    
    func updateVolume() {
        audioPlayer?.volume = Float(volume)
        breathingPlayer?.volume = Float(volume)
    }
    
    func mute() {
        isMuted = true
        audioPlayer?.volume = 0
        breathingPlayer?.volume = 0
    }
    
    func unmute() {
        isMuted = false
        audioPlayer?.volume = Float(volume)
        breathingPlayer?.volume = Float(volume)
    }
    
    func stop() {
        audioPlayer?.stop()
        breathingPlayer?.stop()
        audioPlayer = nil
        breathingPlayer = nil
        isPlaying = false
    }
    
    // MARK: - 音频切换
    func crossFade(to newSound: SoundOption) {
        // 保存当前播放器
        let oldPlayer = audioPlayer
        
        // 准备新的音频
        guard let url = Bundle.main.url(forResource: newSound.fileName, withExtension: "mp3") else {
            print("找不到音频文件: \(newSound.fileName)")
            return
        }
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0
            newPlayer.play()
            
            // 执行淡入淡出
            let fadeOutDuration = 1.0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                oldPlayer?.volume -= Float(0.1)
                newPlayer.volume += Float(0.1 * self.volume)
                
                if oldPlayer?.volume ?? 0 <= 0 {
                    oldPlayer?.stop()
                    timer.invalidate()
                }
            }
            
            audioPlayer = newPlayer
        } catch {
            print("音频切换失败: \(error.localizedDescription)")
        }
    }
    
    func fadeOut(completion: @escaping () -> Void = {}) {
        guard let player = audioPlayer else {
            completion()
            return
        }
        
        let fadeOutDuration = 1.0
        let originalVolume = player.volume
        let steps = 10
        let volumeStep = originalVolume / Float(steps)
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: fadeOutDuration/Double(steps), repeats: true) { timer in
            currentStep += 1
            player.volume = originalVolume - (volumeStep * Float(currentStep))
            
            if currentStep >= steps {
                player.stop()
                player.volume = originalVolume
                timer.invalidate()
                completion()
            }
        }
    }
} 