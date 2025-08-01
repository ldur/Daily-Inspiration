import Foundation

// MARK: - Data Models

struct Challenge: Identifiable, Codable {
    let id = UUID()
    let category: String
    let text: String
    let description: String
}

struct ActionEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let challenge: String
    let category: String
    let baseScore: Int
    let streakBonus: Int
    let totalScore: Int
    let streakDay: Int
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let unlockedDate: Date?
    
    var isUnlocked: Bool {
        unlockedDate != nil
    }
}
