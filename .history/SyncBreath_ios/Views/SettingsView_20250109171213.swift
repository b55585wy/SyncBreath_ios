import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // 呼吸设置
                Section {
                    Stepper(
                        "练习时长: \(viewModel.settings.duration)分钟",
                        value: Binding(
                            get: { viewModel.settings.duration },
                            set: { 
                                var newSettings = viewModel.settings
                                newSettings.duration = $0
                                viewModel.settings = newSettings
                            }
                        ),
                        in: 5...60,
                        step: 5
                    )
                } header: {
                    Text("呼吸设置")
                }
                
                // 声音设置
                Section {
                    Toggle("启用音效", isOn: Binding(
                        get: { viewModel.settings.enableSound },
                        set: { 
                            var newSettings = viewModel.settings
                            newSettings.enableSound = $0
                            viewModel.settings = newSettings
                        }
                    ))
                    
                    if viewModel.settings.enableSound {
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.settings.hardwareIntensity.volume) },
                                set: { 
                                    var newSettings = viewModel.settings
                                    newSettings.hardwareIntensity.volume = Float($0)
                                    viewModel.settings = newSettings
                                }
                            ),
                            in: 0...1
                        ) {
                            Text("音量")
                        }
                    }
                } header: {
                    Text("声音设置")
                }
                
                // 振动设置
                Section {
                    Toggle(
                        "启用振动",
                        isOn: Binding(
                            get: { viewModel.settings.hardwareIntensity.vibration > 0 },
                            set: { 
                                var newSettings = viewModel.settings
                                newSettings.hardwareIntensity.vibration = $0 ? 1.0 : 0.0
                                viewModel.settings = newSettings
                            }
                        )
                    )
                } header: {
                    Text("触觉反馈")
                }
                
                // 显示设置
                Section {
                    Toggle("显示进度", isOn: Binding(
                        get: { viewModel.settings.showProgress },
                        set: { 
                            var newSettings = viewModel.settings
                            newSettings.showProgress = $0
                            viewModel.settings = newSettings
                        }
                    ))
                } header: {
                    Text("显示设置")
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                dismiss()
            })
        }
    }
}

#Preview {
    SettingsView(viewModel: MeditationViewModel())
} 