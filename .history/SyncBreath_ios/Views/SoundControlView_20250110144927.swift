import SwiftUI

struct SoundControlView: View {
    @ObservedObject var audioManager = AudioManager.shared
    @ObservedObject var viewModel: MeditationViewModel
    let meditationType: MeditationType
    @State private var showSoundPicker = false
    
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
            // Sound selection button
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
                // Volume control
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
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView(viewModel: viewModel,
                          soundOptions: soundOptions,
                          meditationType: meditationType)
        }
        .onChange(of: viewModel.selectedSound) { oldValue, newSound in
            if let sound = newSound {
                if audioManager.isPlaying {
                    audioManager.crossFade(to: sound)
                } else {
                    audioManager.playSound(for: meditationType, option: sound)
                }
            }
        }
        .onChange(of: meditationType) { oldValue, newValue in
            // 确保音效列表随模式变化而更新
            if !soundOptions.contains(where: { $0.id == viewModel.selectedSound?.id }) {
                viewModel.selectedSound = soundOptions.first
            }
        }
    }
}

struct SoundPickerView: View {
    @ObservedObject var viewModel: MeditationViewModel
    let soundOptions: [SoundOption]
    let meditationType: MeditationType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(soundOptions) { sound in
                Button(action: {
                    viewModel.updateSoundSelection(sound)
                    dismiss()
                }) {
                    HStack {
                        Text(sound.name)
                        Spacer()
                        if viewModel.selectedSound?.id == sound.id {
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
