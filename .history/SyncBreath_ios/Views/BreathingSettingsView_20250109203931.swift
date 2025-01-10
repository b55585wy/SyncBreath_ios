import SwiftUI

struct BreathingSettingsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var inhaleTime: Double
    @State private var holdTime: Double
    @State private var exhaleTime: Double
    @State private var duration: Int = 15  // 默认15分钟
    
    init(viewModel: MeditationViewModel) {
        self.viewModel = viewModel
        _inhaleTime = State(initialValue: Double(viewModel.currentMode.breathPattern.inhale))
        _holdTime = State(initialValue: Double(viewModel.currentMode.breathPattern.hold))
        _exhaleTime = State(initialValue: Double(viewModel.currentMode.breathPattern.exhale))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("呼吸时长")) {
                    Picker("练习时长", selection: $duration) {
                        ForEach([5, 10, 15, 20, 30], id: \.self) { mins in
                            Text("\(mins)分钟").tag(mins)
                        }
                    }
                }
                
                Section(header: Text("呼吸节奏")) {
                    VStack {
                        Text("吸气时长: \(Int(inhaleTime))秒")
                        Slider(value: $inhaleTime, in: 2...10, step: 1)
                    }
                    
                    VStack {
                        Text("屏气时长: \(Int(holdTime))秒")
                        Slider(value: $holdTime, in: 0...10, step: 1)
                    }
                    
                    VStack {
                        Text("呼气时长: \(Int(exhaleTime))秒")
                        Slider(value: $exhaleTime, in: 2...10, step: 1)
                    }
                }
                
                Section {
                    Button(action: {
                        // 更新呼吸设置
                        viewModel.updateBreathingSettings(
                            duration: duration,
                            pattern: BreathPattern(
                                inhale: Int(inhaleTime),
                                hold: Int(holdTime),
                                exhale: Int(exhaleTime)
                            )
                        )
                        // 开始呼吸训练
                        viewModel.startBreathing()
                        dismiss()
                    }) {
                        Text("开始训练")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("呼吸设置")
            .navigationBarItems(trailing: Button("取消") {
                dismiss()
            })
        }
    }
} 