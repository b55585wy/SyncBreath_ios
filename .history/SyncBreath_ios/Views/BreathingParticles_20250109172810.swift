import SwiftUI

struct BreathingParticles: View {
    let phase: MeditationViewModel.BreathPhase
    let progress: Double
    
    @State private var particles: [(id: Int, position: CGPoint, scale: CGFloat)] = []
    @State private var timer: Timer?
    
    private let particleCount = 12
    private let radius: CGFloat = 150
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // 绘制粒子
                for particle in particles {
                    var context = context
                    context.addFilter(.blur(radius: 2))
                    
                    let path = Path { path in
                        path.addEllipse(in: CGRect(
                            x: particle.position.x - 4,
                            y: particle.position.y - 4,
                            width: 8,
                            height: 8
                        ))
                    }
                    
                    context.opacity = 0.8
                    context.fill(
                        path,
                        with: .color(.white.opacity(0.8))
                    )
                }
            }
            .onChange(of: phase) { _, _ in
                updateParticles()
            }
            .onChange(of: progress) { _, _ in
                updateParticles()
            }
            .onAppear {
                updateParticles()
                startParticleAnimation()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func updateParticles() {
        var newParticles: [(id: Int, position: CGPoint, scale: CGFloat)] = []
        
        for i in 0..<particleCount {
            let angle = (2 * .pi * Double(i)) / Double(particleCount)
            let scale: CGFloat
            
            switch phase {
            case .inhale:
                scale = 1.0 + progress * 0.5
            case .hold:
                scale = 1.5
            case .exhale:
                scale = 1.5 - progress * 0.5
            }
            
            let currentRadius = radius * scale
            let x = UIScreen.main.bounds.width / 2 + cos(angle) * currentRadius
            let y = UIScreen.main.bounds.height / 2 + sin(angle) * currentRadius
            
            newParticles.append((id: i, position: CGPoint(x: x, y: y), scale: scale))
        }
        
        particles = newParticles
    }
    
    private func startParticleAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            updateParticles()
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        BreathingParticles(
            phase: .inhale,
            progress: 0.5
        )
    }
} 