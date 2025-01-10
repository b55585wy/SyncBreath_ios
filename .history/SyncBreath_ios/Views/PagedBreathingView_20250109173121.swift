import SwiftUI

// 提取控制面板视图
private struct ControlPanel: View {
    let meditationType: MeditationType
    let isBreathing: Bool
    let onPlayPause: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Sound control
            SoundControlView(meditationType: meditationType)
                .padding(.horizontal, 24)
            
            // Start/Pause Button
            Button(action: {
                withAnimation(.spring(duration: 0.6)) {
                    onPlayPause()
                }
            }) {
                Image(systemName: isBreathing ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
        }
    }
}

// 提取标题视图
private struct TitleView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(ThemeFonts.titleFont)
                .foregroundColor(.white)
            
            Text(description)
                .font(ThemeFonts.quoteFont)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 100)
    }
}

// 提取页面内容视图
private struct PageContent: View {
    let mode: MeditationType
    @ObservedObject var viewModel: MeditationViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Background and animation
            BreathingAnimationView(
                meditationType: mode,
                phase: $viewModel.currentPhase,
                progress: $viewModel.progress
            )
            
            // Controls overlay
            VStack(spacing: 0) {
                TitleView(title: mode.rawValue, description: mode.description)
                
                Spacer()
                
                // 呼吸阶段指示器
                if viewModel.isBreathing {
                    BreathPhaseIndicator(
                        phase: viewModel.currentPhase,
                        progress: viewModel.progress,
                        pattern: mode.breathPattern
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
                
                // Controls
                ControlPanel(
                    meditationType: mode,
                    isBreathing: viewModel.isBreathing,
                    onPlayPause: {
                        if viewModel.isBreathing {
                            viewModel.pauseBreathing()
                        } else {
                            viewModel.startBreathing()
                            viewModel.switchMode(mode)
                        }
                    }
                )
                .padding(.bottom, geometry.safeAreaInsets.bottom + 50)
            }
            
            // 粒子效果
            if viewModel.isBreathing {
                BreathingParticles(
                    phase: viewModel.currentPhase,
                    progress: viewModel.progress
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct PagedBreathingView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var currentPage = 0
    @State private var showSettings = false
    
    private let modes = MeditationType.allCases
    
    private func themeColor(for type: MeditationType) -> Color {
        switch type {
        case .bambooGrove:
            return AppTheme.colors.bambooGradient[0]
        case .cloudReturn:
            return AppTheme.colors.cloudGradient[0]
        case .starryNight:
            return AppTheme.colors.starryGradient[0]
        case .mountainSpring:
            return AppTheme.colors.mountainGradient[0]
        case .zenMoment:
            return AppTheme.colors.zenGradient[0]
        case .seasonCycle:
            return AppTheme.colors.seasonColors.currentSeasonColors()[0]
        }
    }
    
    private var currentThemeColor: Color {
        themeColor(for: modes[currentPage])
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(modes.indices, id: \.self) { index in
                    GeometryReader { geometry in
                        PageContent(
                            mode: modes[index],
                            viewModel: viewModel,
                            geometry: geometry
                        )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentPage) { oldValue, newValue in
                if oldValue != newValue {
                    hapticFeedback()
                    viewModel.switchMode(modes[newValue])
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(currentThemeColor)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden)
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(currentThemeColor)
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    PagedBreathingView()
}
