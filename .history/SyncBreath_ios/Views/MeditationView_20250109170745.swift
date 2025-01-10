struct MeditationView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景动画
                BreathingAnimationView(
                    meditationType: viewModel.currentMode.type,
                    phase: $viewModel.currentPhase,
                    progress: $viewModel.progress
                )
                
                VStack {
                    // 模式标题和描述
                    VStack(spacing: 8) {
                        Text(viewModel.currentMode.title)
                            .font(ThemeFonts.titleFont)
                            .foregroundColor(.white)
                        
                        Text(viewModel.currentMode.description)
                            .font(ThemeFonts.quoteFont)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // 控制面板
                    VStack(spacing: 20) {
                        // 音效控制
                        SoundControlView(meditationType: viewModel.currentMode.type)
                            .padding(.horizontal)
                        
                        // 开始/暂停按钮
                        Button(action: {
                            if viewModel.isBreathing {
                                viewModel.pauseBreathing()
                            } else {
                                viewModel.startBreathing()
                            }
                        }) {
                            Image(systemName: viewModel.isBreathing ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
} 