import SwiftUI

/// 音效控制视图，用于管理冥想音效的选择和音量控制
/// 包含音效选择器和音量滑块，支持实时音效切换和音量调节
struct SoundControlView: View {
    // MARK: - Properties
    /// 音频管理器单例，负责处理音频播放和控制
    @ObservedObject var audioManager = AudioManager.shared
    /// 冥想视图模型，包含选中的音效等状态
    @ObservedObject var viewModel: MeditationViewModel
    /// 当前冥想类型
    let meditationType: MeditationType
    /// 控制音效选择器sheet的显示状态
    @State private var showSoundPicker = false
    
    /// 根据冥想类型返回对应的音效选项列表
    private var soundOptions: [SoundOption] {
        switch meditationType {
        case .bambooGrove:
            return SoundOption.bambooGroveOptions
        case .cloudReturn:
            return SoundOption.cloudReturnOptions
        case .starryNight:
            return SoundOption.starryNightOptions
        case .mountainSpring:
            return SoundOption.mountainSpringOptions
        case .zenMoment:
            return SoundOption.zenMomentOptions
        case .seasonCycle:
            return SoundOption.seasonOptions
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 音效选择按钮
            Button(action: {
                showSoundPicker = true
            }) {
                HStack {
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                    Text(viewModel.selectedSound?.name ?? "选择音效")
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                }
                .foregroundColor(.white)
                .padding()
                .frame(height: 44)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
            
            if viewModel.selectedSound != nil {
                // MARK: - 音量控制滑块
                HStack {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                    Slider(value: $audioManager.volume, in: 0...1) { _ in
                        audioManager.updateVolume()
                    }
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        // MARK: - 音效选择器Sheet
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView(selectedSound: $viewModel.selectedSound,
                          soundOptions: soundOptions,
                          meditationType: meditationType)
        }
        // MARK: - 音效切换处理
        .onChange(of: viewModel.selectedSound) { oldValue, newSound in
            if let sound = newSound {
                if audioManager.isPlaying {
                    audioManager.crossFade(to: sound)
                } else {
                    audioManager.playSound(for: meditationType, option: sound)
                }
            }
        }
    }
}

/// 音效选择器视图，以列表形式展示可选音效
/// 支持选择音效并显示当前选中状态
struct SoundPickerView: View {
    // MARK: - Properties
    /// 绑定选中的音效
    @Binding var selectedSound: SoundOption?
    /// 可选音效列表
    let soundOptions: [SoundOption]
    /// 当前冥想类型
    let meditationType: MeditationType
    /// 用于关闭sheet的环境变量
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(soundOptions) { sound in
                Button(action: {
                    selectedSound = sound
                    dismiss()
                }) {
                    HStack {
                        Text(sound.name)
                        Spacer()
                        if selectedSound?.id == sound.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("选择音效")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SoundControlView(viewModel: MeditationViewModel(), meditationType: .bambooGrove)
        .preferredColorScheme(.dark)
}
