import SwiftUI

struct MeditationPageView: View {
    let meditationType: MeditationType
    @ObservedObject var viewModel: MeditationViewModel
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        ZStack {
            // Background and animation
            BreathingAnimationView(
                meditationType: meditationType,
                phase: $viewModel.currentPhase,
                progress: $viewModel.progress
            )
            
            // Controls overlay
            VStack {
                // Mode title and quote
                VStack(spacing: 8) {
                    Text(meditationType.rawValue)
                        .font(ThemeFonts.titleFont)
                        .foregroundColor(.white)
                    
                    Text(meditationType.description)
                        .font(ThemeFonts.quoteFont)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Controls
                VStack(spacing: 20) {
                    // Sound control
                    SoundControlView(meditationType: meditationType)
                        .padding(.horizontal)
                    
                    // Start/Pause Button
                    Button(action: {
                        if viewModel.isBreathing {
                            viewModel.pauseBreathing()
                            bluetoothManager.stopBreathing()
                        } else {
                            viewModel.startBreathing()
                            bluetoothManager.startBreathing(
                                inhaleTime: viewModel.inhaleTime,
                                exhaleTime: viewModel.exhaleTime
                            )
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
    }
}

struct SettingsButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
                .padding()
            }
            Spacer()
        }
    }
}

struct PagedBreathingView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var currentPage = 0
    @State private var showSettings = false
    
    private let modes = MeditationType.allCases
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(modes.indices, id: \.self) { index in
                        MeditationPageView(
                            meditationType: modes[index],
                            viewModel: viewModel,
                            bluetoothManager: bluetoothManager
                        )
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
                
                SettingsButton {
                    showSettings = true
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSettings) {
            DeviceSettingsView()
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    PagedBreathingView()
}
