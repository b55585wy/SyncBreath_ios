import SwiftUI

struct BreathPhaseIndicator: View {
    let phase: MeditationViewModel.BreathPhase
    let progress: Double
    let pattern: BreathPattern
    
    private var currentPhaseDuration: Int {
        switch phase {
        case .inhale:
            return pattern.inhale
        case .hold:
            return pattern.hold
        case .exhale:
            return pattern.exhale
        }
    }
    
    private var remainingSeconds: Int {
        Int(ceil(Double(currentPhaseDuration) * (1 - progress)))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 阶段名称
            Text(phase.rawValue)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            
            // 倒计时
            Text("\(remainingSeconds)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.snappy, value: remainingSeconds)
            
            // 进度条
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))
                    .frame(width: 200, height: 4)
                
                Capsule()
                    .fill(.white)
                    .frame(width: 200 * progress, height: 4)
            }
            .animation(.smooth, value: progress)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        
        BreathPhaseIndicator(
            phase: .inhale,
            progress: 0.7,
            pattern: BreathPattern(inhale: 4, hold: 4, exhale: 4)
        )
    }
} 