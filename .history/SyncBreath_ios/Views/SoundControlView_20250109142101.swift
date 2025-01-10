import SwiftUI

struct SoundControlView: View {
    @ObservedObject var audioManager = AudioManager.shared
    let meditationType: MeditationType
    @State private var selectedSound: SoundOption?
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
                    Text(selectedSound?.name ?? "选择音效")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
            
            if selectedSound != nil {
                // Volume control
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.white)
                    Slider(value: $audioManager.volume, in: 0...1) { _ in
                        audioManager.updateVolume()
                    }
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView(selectedSound: $selectedSound,
                          soundOptions: soundOptions,
                          meditationType: meditationType)
        }
        .onChange(of: selectedSound) { oldValue, newSound in
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

struct SoundPickerView: View {
    @Binding var selectedSound: SoundOption?
    let soundOptions: [SoundOption]
    let meditationType: MeditationType
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
    SoundControlView(meditationType: .bambooGrove)
        .preferredColorScheme(.dark)
}
