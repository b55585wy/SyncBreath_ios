import SwiftUI

struct BreathingAnimationView: View {
    let meditationType: MeditationType
    @Binding var phase: MeditationViewModel.BreathingPhase
    @Binding var progress: Double
    
    private let bambooGroveColor = Color(red: 0.4, green: 0.6, blue: 0.4)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        bambooGroveColor,
                        bambooGroveColor.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // 呼吸动画
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.8)
                    .scaleEffect(phase == .inhale ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 4), value: phase)
                
                // 进度环
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.white.opacity(0.6), lineWidth: 4)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.8)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
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
