import SwiftUI

// MARK: - Main Content View (COMPLETE VERSION)

struct ContentView: View {
    @StateObject private var gameState = GameStateManager()
    @State private var currentChallenge: Challenge?
    @State private var showingAnalytics = false
    @State private var showingCompletionMessage = false
    @State private var completionMessageText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.5, blue: 0.9),
                        Color(red: 0.46, green: 0.3, blue: 0.64)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Text("💕 Sammen Hver Dag")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Daglige utfordringer som inspirerer til positiv vekst for deg og din partner")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Date Display
                        Text(formattedDate())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.42),
                                        Color(red: 1.0, green: 0.56, blue: 0.56)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        // Challenge Card
                        if let challenge = currentChallenge {
                            ChallengeCardView(
                                challenge: challenge,
                                gameState: gameState,
                                onAcceptChallenge: {
                                    gameState.acceptChallenge()
                                    showCompletionMessage("🌟 Utfordring godtatt! Dere klarer dette sammen! 🌟")
                                },
                                onMarkCompleted: {
                                    let points = gameState.getCategoryScore(challenge.category) + min(gameState.dailyStreak * 2, 20)
                                    gameState.markCompleted()
                                    showCompletionMessage("🎉 Fantastisk! Dere har fullført dagens utfordring sammen!\nPoeng oppnådd: \(points)\nBåndet deres blir sterkere for hver positive handling. 💕")
                                },
                                onNewChallenge: {
                                    currentChallenge = gameState.getNewChallenge()
                                }
                            )
                        }
                        
                        // Completion Message
                        if showingCompletionMessage {
                            Text(completionMessageText)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.59, green: 0.81, blue: 0.71),
                                            Color(red: 0.52, green: 0.83, blue: 0.65)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Progress Section
                        ProgressSectionView(gameState: gameState)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAnalytics = true }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
        }
        .onAppear {
            currentChallenge = gameState.getDailyChallenge()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView(gameState: gameState)
        }
        .confetti(isPresented: $gameState.showingCelebration) // 🎉 FIXED CONFETTI!
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    private func showCompletionMessage(_ message: String) {
        completionMessageText = message
        withAnimation(.easeInOut(duration: 0.5)) {
            showingCompletionMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showingCompletionMessage = false
            }
        }
    }
}
