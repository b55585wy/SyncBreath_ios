import SwiftUI

struct BreathingAnimationView: View {
    let meditationType: MeditationType
    @Binding var phase: MeditationViewModel.BreathPhase
    @Binding var progress: Double
    
    @State private var previousType: MeditationType? = nil
    @State private var isTransitioning = false
    
    private var scale: CGFloat {
        switch phase {
        case .inhale:
            return 1.0 + progress * 0.3
        case .hold:
            return 1.3
        case .exhale:
            return 1.3 - progress * 0.3
        }
    }
    
    private var opacity: Double {
        switch phase {
        case .inhale:
            return 0.5 + progress * 0.5
        case .hold:
            return 1.0
        case .exhale:
            return 1.0 - progress * 0.5
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient based on meditation type
            backgroundGradient
                .animation(.easeInOut(duration: 1.0), value: meditationType)
                .ignoresSafeArea()
            
            // Main breathing animation
            ZStack {
                // Current animation
                createAnimationView(for: meditationType)
                    .opacity(isTransitioning ? 0 : 1)
                    .offset(x: isTransitioning ? -UIScreen.main.bounds.width : 0)
                
                // Previous animation (if exists)
                if let previousType = previousType {
                    createAnimationView(for: previousType)
                        .opacity(isTransitioning ? 1 : 0)
                        .offset(x: isTransitioning ? 0 : UIScreen.main.bounds.width)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isTransitioning)
        }
        .onChange(of: meditationType) { newType in
            handleTypeChange(newType)
        }
    }
    
    private func createAnimationView(for type: MeditationType) -> some View {
        Group {
            switch type {
            case .bambooGrove:
                BambooAnimation(scale: scale, opacity: opacity)
            case .cloudReturn:
                CloudAnimation(scale: scale, opacity: opacity)
            case .starryNight:
                StarryAnimation(scale: scale, opacity: opacity)
            case .mountainSpring:
                MountainSpringAnimation(scale: scale, opacity: opacity)
            case .zenMoment:
                ZenCircleAnimation(scale: scale, opacity: opacity)
            case .seasonCycle:
                SeasonalAnimation(scale: scale, opacity: opacity)
            }
        }
    }
    
    private func handleTypeChange(_ newType: MeditationType) {
        previousType = meditationType
        isTransitioning = true
        
        // Delay and reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTransitioning = false
            previousType = nil
        }
    }
    
    private var backgroundGradient: some View {
        let colors: [Color]
        switch meditationType {
        case .bambooGrove:
            colors = AppTheme.colors.bambooGradient
        case .cloudReturn:
            colors = AppTheme.colors.cloudGradient
        case .starryNight:
            colors = AppTheme.colors.starryGradient
        case .mountainSpring:
            colors = AppTheme.colors.mountainGradient
        case .zenMoment:
            colors = AppTheme.colors.zenGradient
        case .seasonCycle:
            colors = AppTheme.colors.seasonColors.currentSeasonColors()
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Animation Components
struct BambooAnimation: View {
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.white)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

struct CloudAnimation: View {
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 120, height: 120)
            .foregroundColor(.white)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

struct StarryAnimation: View {
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.white)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

struct MountainSpringAnimation: View {
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Mountain silhouette
            Image(systemName: "mountain.2.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 120)
                .foregroundColor(.white.opacity(0.3))
                .offset(y: 40)
            
            // Flowing water drops
            ForEach(0..<3) { index in
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                    .offset(x: CGFloat(index - 1) * 50)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
    }
}

struct ZenCircleAnimation: View {
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 150, height: 150)
            
            // Inner circle that scales with breathing
            Circle()
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
        }
    }
}

struct SeasonSymbol: View {
    let index: Int
    
    var symbolImage: Image {
        switch index {
        case 0: // Spring
            return Image(systemName: "leaf.fill")
        case 1: // Summer
            return Image(systemName: "sun.max.fill")
        case 2: // Autumn
            return Image(systemName: "leaf.arrow.triangle.circlepath")
        case 3: // Winter
            return Image(systemName: "snowflake")
        default:
            return Image(systemName: "leaf.fill")
        }
    }
    
    var body: some View {
        symbolImage
            .resizable()
            .aspectRatio(contentMode: ContentMode.fit)
            .frame(width: 40, height: 40)
            .foregroundColor(Color.white)
            .offset(x: 0, y: -60)
            .rotationEffect(Angle.degrees(Double(index) * 90))
    }
}

struct SeasonalAnimation: View {
    let scale: CGFloat
    let opacity: Double
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    SeasonSymbol(index: index)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(Angle.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    BreathingAnimationView(
        meditationType: .bambooGrove,
        phase: .constant(.inhale),
        progress: .constant(0.5)
    )
}
