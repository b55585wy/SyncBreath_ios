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
                            VStack {
                                // Mode title and quote
                                VStack(spacing: 8) {
                                    Text(modes[index].rawValue)
                                        .font(ThemeFonts.titleFont)
                                        .foregroundColor(.white)
                                    
                                    Text(modes[index].description)
                                        .font(ThemeFonts.quoteFont)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.top, 20)
                                
                                Spacer()
                                
                                // Controls
                                VStack(spacing: 20) {
                                    // Sound control
                                    SoundControlView(meditationType: modes[index])
                                        .padding(.horizontal)
                                    
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
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.white)
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
                .onChange(of: currentPage) { oldValue, newValue in
                    if oldValue != newValue {
                        hapticFeedback()
                        viewModel.switchMode(modes[newValue])
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(currentThemeColor)
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(.white)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    PagedBreathingView()
}
