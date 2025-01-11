import SwiftUI

// 呼吸设置视图：用于配置呼吸练习的各项参数，包括练习时长和呼吸节奏
struct BreathingSettingsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: MeditationViewModel
    @Environment(\.dismiss) var dismiss
    
    // 呼吸相关的状态变量
    @State private var inhaleTime: Double    // 吸气时长(秒)
    @State private var holdTime: Double      // 屏气时长(秒)
    @State private var exhaleTime: Double    // 呼气时长(秒)
    @State private var duration: Int = 15    // 练习总时长(分钟)，默认15分钟
    
    // MARK: - Initialization
    // 初始化方法：从viewModel中获取当前呼吸模式的参数值
    init(viewModel: MeditationViewModel) {
        self.viewModel = viewModel
        // 使用 State 包装器初始化呼吸参数
        _inhaleTime = State(initialValue: Double(viewModel.currentMode.breathPattern.inhale))
        _holdTime = State(initialValue: Double(viewModel.currentMode.breathPattern.hold))
        _exhaleTime = State(initialValue: Double(viewModel.currentMode.breathPattern.exhale))
    }
    
    // MARK: - View
    var body: some View {
        NavigationView {
            Form {
                // 练习时长选择区域
                Section(header: Text("呼吸时长").font(.headline)) {
                    // 使用滚轮选择器来选择练习时长
                    Picker("练习时长", selection: $duration) {
                        ForEach([5, 10, 15, 20, 30], id: \.self) { mins in
                            Text("\(mins)分钟")
                                .font(.body)
                                .tag(mins)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                // 呼吸节奏设置区域
                Section(header: Text("呼吸节奏").font(.headline)) {
                    // 吸气时长滑块：2-10秒范围
                    VStack(spacing: 8) {
                        Text("吸气时长: \(Int(inhaleTime))秒")
                            .font(.body)
                        Slider(value: $inhaleTime, in: 2...10, step: 1)
                            .frame(height: 44)
                    }
                    
                    // 屏气时长滑块：0-10秒范围
                    VStack(spacing: 8) {
                        Text("屏气时长: \(Int(holdTime))秒")
                            .font(.body)
                        Slider(value: $holdTime, in: 0...10, step: 1)
                            .frame(height: 44)
                    }
                    
                    // 呼气时长滑块：2-10秒范围
                    VStack(spacing: 8) {
                        Text("呼气时长: \(Int(exhaleTime))秒")
                            .font(.body)
                        Slider(value: $exhaleTime, in: 2...10, step: 1)
                            .frame(height: 44)
                    }
                }
                
                // 开始训练按钮区域
                Section {
                    Button(action: {
                        // 1. 更新呼吸设置到 ViewModel
                        viewModel.updateBreathingSettings(
                            duration: duration,
                            pattern: BreathPattern(
                                inhale: Int(inhaleTime),
                                hold: Int(holdTime),
                                exhale: Int(exhaleTime)
                            )
                        )
                        // 2. 开始呼吸训练
                        viewModel.startBreathing()
                        // 3. 关闭设置视图
                        dismiss()
                    }) {
                        Text("开始训练")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
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