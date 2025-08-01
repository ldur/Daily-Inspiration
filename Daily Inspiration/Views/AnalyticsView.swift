import SwiftUI

// MARK: - Analytics View

struct AnalyticsView: View {
    @ObservedObject var gameState: GameStateManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab Selection
                Picker("Tab", selection: $selectedTab) {
                    Text("🎯 Handlinger").tag(0)
                    Text("📈 Statistikk").tag(1)
                    Text("🏆 Prestasjoner").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    ActionsListView(gameState: gameState)
                        .tag(0)
                    
                    StatsView(gameState: gameState)
                        .tag(1)
                    
                    AchievementsView(gameState: gameState)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("📊 Analyse")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Ferdig") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Actions List View

struct ActionsListView: View {
    @ObservedObject var gameState: GameStateManager
    
    var body: some View {
        List {
            if gameState.actionLog.isEmpty {
                Text("Ingen handlinger registrert ennå.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(gameState.actionLog) { action in
                    ActionItemView(action: action)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ActionItemView: View {
    let action: ActionEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDate(action.date))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(action.challenge)
                .font(.body)
                .fontWeight(.medium)
            
            HStack {
                Text(action.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(action.totalScore) poeng")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Stats View

struct StatsView: View {
    @ObservedObject var gameState: GameStateManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Kategori-analyse")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if gameState.categoryStats.isEmpty {
                        Text("Ingen kategoridata ennå.")
                            .foregroundColor(.secondary)
                            .italic()
                            .padding()
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(Array(gameState.categoryStats.keys.sorted()), id: \.self) { category in
                                CategoryStatView(
                                    category: category,
                                    count: gameState.categoryStats[category] ?? 0
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Score Breakdown
                VStack(alignment: .leading, spacing: 10) {
                    Text("Poengfordeling")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ScoreStatView(
                            label: "Totale poeng",
                            value: "\(gameState.totalScore)"
                        )
                        
                        ScoreStatView(
                            label: "Gjennomsnitt",
                            value: gameState.totalChallenges > 0 ? "\(gameState.totalScore / gameState.totalChallenges)" : "0"
                        )
                        
                        ScoreStatView(
                            label: "Beste rekke",
                            value: "\(gameState.getBestStreak())"
                        )
                        
                        ScoreStatView(
                            label: "Denne måneden",
                            value: "\(gameState.weeklyCompleted * 4)"
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct CategoryStatView: View {
    let category: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(category)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ScoreStatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.59, green: 0.81, blue: 0.71),
                    Color(red: 0.52, green: 0.83, blue: 0.65)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @ObservedObject var gameState: GameStateManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Unlocked Achievements
                VStack(alignment: .leading, spacing: 10) {
                    Text("Opplåste prestasjoner")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if gameState.achievements.isEmpty {
                        Text("Ingen prestasjoner opplåst ennå.")
                            .foregroundColor(.secondary)
                            .italic()
                            .padding()
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(gameState.achievements) { achievement in
                                AchievementItemView(achievement: achievement, isUnlocked: true)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Upcoming Achievements
                VStack(alignment: .leading, spacing: 10) {
                    Text("Kommende mål")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(upcomingAchievements(), id: \.id) { achievement in
                            AchievementItemView(achievement: achievement, isUnlocked: false)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func upcomingAchievements() -> [Achievement] {
        let allAchievements = [
            Achievement(id: "monthly_master", title: "Månedens mester", description: "Fullføre 30 utfordringer på en måned", icon: "🌙", unlockedDate: nil),
            Achievement(id: "thousand_points", title: "Tusenpoenger", description: "Oppnå 1000 totale poeng", icon: "💎", unlockedDate: nil),
            Achievement(id: "streak_king", title: "Rekkekongen", description: "Oppnå 30 dagers rekke", icon: "👑", unlockedDate: nil)
        ]
        
        return allAchievements.filter { upcoming in
            !gameState.achievements.contains { unlocked in unlocked.id == upcoming.id }
        }
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.largeTitle)
            
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            isUnlocked ?
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.6, blue: 0.34),
                    Color(red: 1.0, green: 0.65, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(isUnlocked ? .white : .secondary)
        .cornerRadius(10)
    }
}
