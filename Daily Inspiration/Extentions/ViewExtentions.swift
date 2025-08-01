import SwiftUI
import UIKit

// MARK: - View Extensions and Effects

// MARK: - FIXED Confetti Effect

struct ConfettiView: UIViewRepresentable {
    @Binding var isPresented: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        // 🔧 FIX: Allow touches to pass through when not showing confetti
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 🔧 FIX: Only enable interaction when actually showing confetti
        uiView.isUserInteractionEnabled = isPresented
        
        if isPresented {
            let emitter = CAEmitterLayer()
            emitter.emitterPosition = CGPoint(x: uiView.bounds.midX, y: -10)
            emitter.emitterShape = .line
            emitter.emitterSize = CGSize(width: uiView.bounds.width, height: 1)
            
            let cell = CAEmitterCell()
            cell.birthRate = 50
            cell.lifetime = 3
            cell.velocity = 100
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.scale = 0.5
            cell.scaleRange = 0.3
            cell.contents = UIImage(systemName: "heart.fill")?.cgImage
            cell.color = UIColor.red.cgColor
            
            emitter.emitterCells = [cell]
            uiView.layer.addSublayer(emitter)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                emitter.removeFromSuperlayer()
                // 🔧 FIX: Disable interaction after confetti finishes
                uiView.isUserInteractionEnabled = false
                isPresented = false
            }
        }
    }
}

extension View {
    func confetti(isPresented: Binding<Bool>) -> some View {
        // 🔧 FIX: Only add overlay when actually needed
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    ConfettiView(isPresented: isPresented)
                } else {
                    EmptyView()
                }
            }
        )
    }
}

// MARK: - Floating Hearts Animation

struct FloatingHeart: View {
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text("💕")
            .font(.title)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2)) {
                    offset = -200
                    opacity = 0
                }
            }
    }
}

struct CelebrationOverlay: View {
    @State private var hearts: [UUID] = []
    
    var body: some View {
        ForEach(hearts, id: \.self) { id in
            FloatingHeart()
                .position(
                    x: CGFloat.random(in: 50...300),
                    y: UIScreen.main.bounds.height
                )
        }
        .onAppear {
            for _ in 0..<8 {
                hearts.append(UUID())
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                hearts.removeAll()
            }
        }
    }
}

// MARK: - Custom Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct GradientButtonStyle: ViewModifier {
    let colors: [Color]
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: colors[0].opacity(0.4), radius: 5, x: 0, y: 3)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func gradientButton(colors: [Color]) -> some View {
        modifier(GradientButtonStyle(colors: colors))
    }
}

// MARK: - Gradient Background Component

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.5, blue: 0.9),
                Color(red: 0.46, green: 0.3, blue: 0.64)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview Helpers

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
