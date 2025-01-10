import SwiftUI

struct PagedBreathingView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var currentPage = 0
    @State private var showSettings = false
    
    private let modes = MeditationType.allCases
    
    private var currentThemeColor: Color {
        switch modes[currentPage] {
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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $currentPage) {
                    ForEach(modes.indices, id: \.self) { index in
                        ZStack {
                            // Background and animation
                            BreathingAnimationView(
                                meditationType: modes[index],
                                phase: $viewModel.currentPhase,
                                progress: $viewModel.progress
                            )
                            
                            // Controls overlay
                            VStack(spacing: 0) {
                                // Mode title and quote
                                VStack(spacing: 8) {
                                    Text(modes[index].rawValue)
                                        .font(ThemeFonts.titleFont)
                                        .foregroundColor(.white)
                                    
                                    Text(modes[index].description)
                                        .font(ThemeFonts.quoteFont)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.top, 100)
                                
                                Spacer()
                                
                                // Controls
                                VStack(spacing: 30) {
                                    // Sound control
                                    SoundControlView(meditationType: modes[index])
                                        .padding(.horizontal, 24)
                                    
                                    // Start/Pause Button
                                    Button(action: {
                                        if viewModel.isBreathing {
                                            viewModel.pauseBreathing()
                                        } else {
                                            viewModel.startBreathing()
                                            viewModel.switchMode(modes[index])
                                        }
                                    }) {
                                        Image(systemName: viewModel.isBreathing ? "pause.circle.fill" : "play.circle.fill")
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
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 50)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
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
            }
            .ignoresSafeArea()
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
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    PagedBreathingView()
}
