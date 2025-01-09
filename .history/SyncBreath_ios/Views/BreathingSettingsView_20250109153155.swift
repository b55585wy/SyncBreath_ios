import SwiftUI

struct BreathingSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var settings: BreathingSettings
    var onStart: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("呼吸练习设置")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top)
                var duration: Int {
                    switch self {
                    case .inhale: return settings.breathingPattern.inhale
                    case .hold: return settings.breathingPattern.hold
                    case .exhale: return settings.breathingPattern.exhale
                    }
                }
                ScrollView {
                    VStack(spacing: 24) {
                        // 练习时长
                        VStack(alignment: .leading, spacing: 12) {
                            Text("练习时长：\(settings.duration)分钟")
                                .font(.headline)
                            
                            Slider(value: .init(
                                get: { Double(settings.duration) },
                                set: { settings.duration = Int($0) }
                            ), in: 5...60, step: 5)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // 呼吸节奏
                        VStack(alignment: .leading, spacing: 12) {
                            Text("呼吸节奏")
                                .font(.headline)
                            
                            HStack {
                                VStack {
                                    Text("吸气")
                                    Stepper("\(settings.breathingPattern.inhale)秒", value: $settings.breathingPattern.inhale, in: 2...10)
                                }
                                
                                VStack {
                                    Text("屏息")
                                    Stepper("\(settings.breathingPattern.hold)秒", value: $settings.breathingPattern.hold, in: 2...10)
                                }
                                
                                VStack {
                                    Text("呼气")
                                    Stepper("\(settings.breathingPattern.exhale)秒", value: $settings.breathingPattern.exhale, in: 2...10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // 辅助强度
                        VStack(alignment: .leading, spacing: 12) {
                            Text("辅助强度")
                                .font(.headline)
                            
                            VStack(spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("电机：\(Int(settings.hardwareIntensity.motor * 100))%")
                                    Slider(value: $settings.hardwareIntensity.motor)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("气泵：\(Int(settings.hardwareIntensity.pump * 100))%")
                                    Slider(value: $settings.hardwareIntensity.pump)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                }
                
                // 开始按钮
                Button(action: {
                    dismiss()
                    onStart()
                }) {
                    Text("开始")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .foregroundColor(.white)
            .background(Color(red: 0.4, green: 0.6, blue: 0.4))
            .navigationTitle("呼吸练习设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    BreathingSettingsView(
        settings: .constant(BreathingSettings()),
        onStart: {}
    )
}
