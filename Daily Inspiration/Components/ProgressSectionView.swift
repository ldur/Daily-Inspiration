import SwiftUI

// MARK: - Progress Section View

struct ProgressSectionView: View {
    @ObservedObject var gameState: GameStateManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("🌟 Deres reise sammen")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ProgressItem(
                    title: "Dagers rekke",
                    value: "\(gameState.dailyStreak)",
                    icon: "🔥"
                )
                
                ProgressItem(
                    title: "Fullført",
                    value: "\(gameState.totalChallenges)",
                    icon: "🎯"
                )
                
                ProgressItem(
                    title: "Denne uken",
                    value: "\(min(gameState.weeklyCompleted, 7))/7",
                    icon: "📅"
                )
                
                ProgressItem(
                    title: "Totale poeng",
                    value: "\(gameState.totalScore)",
                    icon: "⭐"
                )
            }
        }
        .padding(25)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct ProgressItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(15)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
