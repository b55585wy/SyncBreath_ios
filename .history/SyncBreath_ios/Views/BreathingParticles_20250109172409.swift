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
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                // 绘制粒子
                for particle in particles {
                    let path = Path { path in
                        path.addEllipse(in: CGRect(
                            x: particle.position.x - 4,
                            y: particle.position.y - 4,
                            width: 8,
                            height: 8
                        ))
                    }
                    
                    context.addFilter(.blur(radius: 2))
                    context.setAlpha(0.8)
                    
                    context.fill(
                        path,
                        with: .color(.white.opacity(0.8))
                    )
                }
            }
            .onChange(of: phase) { oldValue, newValue in
                updateParticles()
            }
            .onChange(of: progress) { oldValue, newValue in
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
    }
    
    private func updateParticles() {
        let center = CGPoint(x: radius, y: radius)
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
            let x = center.x + cos(angle) * currentRadius
            let y = center.y + sin(angle) * currentRadius
            
            newParticles.append((id: i, position: CGPoint(x: x, y: y), scale: scale))
        }
        
        particles = newParticles
    }
    
    private func startParticleAnimation() {
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