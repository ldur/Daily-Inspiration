import SwiftUI

// MARK: - Challenge Card View

struct ChallengeCardView: View {
    let challenge: Challenge
    @ObservedObject var gameState: GameStateManager
    let onAcceptChallenge: () -> Void
    let onMarkCompleted: () -> Void
    let onNewChallenge: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Category Badge
            Text(challenge.category)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.31, green: 0.8, blue: 0.77),
                            Color(red: 0.27, green: 0.63, blue: 0.55)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
            
            // Challenge Text
            Text(challenge.text)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Description
            Text(challenge.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Action Buttons
            VStack(spacing: 12) {
                HStack(spacing: 15) {
                    if !gameState.challengeAccepted && !gameState.todayCompleted {
                        ActionButton(
                            title: "✨ Godta utfordring",
                            colors: [
                                Color(red: 0.4, green: 0.5, blue: 0.9),
                                Color(red: 0.46, green: 0.3, blue: 0.64)
                            ],
                            action: onAcceptChallenge
                        )
                    }
                    
                    ActionButton(
                        title: "🔄 Ny utfordring",
                        colors: [
                            Color(red: 0.31, green: 0.8, blue: 0.77),
                            Color(red: 0.27, green: 0.63, blue: 0.55)
                        ],
                        action: onNewChallenge
                    )
                }
                
                if gameState.challengeAccepted && !gameState.todayCompleted {
                    ActionButton(
                        title: "✅ Marker som fullført",
                        colors: [
                            Color(red: 0.59, green: 0.81, blue: 0.71),
                            Color(red: 0.52, green: 0.83, blue: 0.65)
                        ],
                        action: onMarkCompleted
                    )
                }
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
