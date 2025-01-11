import SwiftUI

/// 分页式呼吸冥想视图，支持多种呼吸模式的切换和控制
struct PagedBreathingView: View {
    // MARK: - 状态管理
    /// 冥想状态管理器
    @StateObject private var viewModel = MeditationViewModel()
    /// 音频管理器单例
    @StateObject private var audioManager = AudioManager.shared
    /// 当前显示的页面索引
    @State private var currentPage = 0
    /// 控制呼吸设置页面的显示状态
    @State private var showBreathingSettings = false
    
    /// 所有可用的冥想模式
    private let modes = MeditationType.allCases
    
    var body: some View {
        GeometryReader { geometry in
            // MARK: - 分页视图
            TabView(selection: $currentPage) {
                ForEach(modes.indices, id: \.self) { index in
                    ZStack {
                        // MARK: - 呼吸动画层
                        BreathingAnimationView(
                            meditationType: modes[index],
                            phase: $viewModel.currentPhase,
                            progress: $viewModel.progress
                        )
                        
                        // MARK: - 控制界面层
                        VStack {
                            // MARK: - 标题区域
                            VStack(spacing: 8) {
                                // 呼吸模式标题
                                Text(modes[index].rawValue)
                                    .font(ThemeFonts.titleFont)
                                    .foregroundColor(.white)
                                
                                // 模式描述文字
                                Text(modes[index].description)
                                    .font(ThemeFonts.quoteFont)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, 60)
                            
                            Spacer()
                            
                            // MARK: - 控制区域
                            VStack(spacing: 20) {
                                // 音频控制组件
                                SoundControlView(viewModel: viewModel, meditationType: modes[index])
                                    .padding(.horizontal)
                                
                                // 开始/暂停按钮
                                Button(action: {
                                    if viewModel.isBreathing {
                                        viewModel.pauseBreathing()
                                    } else {
                                        showBreathingSettings = true
                                    }
                                }) {
                                    Image(systemName: viewModel.isBreathing ? "pause.circle.fill" : "play.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                }
                                .sheet(isPresented: $showBreathingSettings) {
                                    BreathingSettingsView(viewModel: viewModel)
                                }
                            }
                            .padding(.bottom, 50)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // MARK: - 页面切换处理
            .onChange(of: currentPage) { oldValue, newValue in
                if oldValue != newValue {
                    hapticFeedback() // 触发触觉反馈
                    viewModel.switchMode(modes[newValue]) // 切换呼吸模式
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    /// 提供页面切换时的触觉反馈
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    PagedBreathingView()
}
