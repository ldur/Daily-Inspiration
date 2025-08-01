import Foundation
import SwiftUI

// MARK: - Game State Manager

class GameStateManager: ObservableObject {
    @Published var dailyStreak: Int = 0
    @Published var totalChallenges: Int = 0
    @Published var weeklyCompleted: Int = 0
    @Published var totalScore: Int = 0
    @Published var challengeAccepted: Bool = false
    @Published var todayCompleted: Bool = false
    @Published var actionLog: [ActionEntry] = []
    @Published var categoryStats: [String: Int] = [:]
    @Published var achievements: [Achievement] = []
    @Published var showingCelebration: Bool = false
    
    private var lastCompletedDate: String = ""
    private var lastWeeklyReset: String = ""
    
    init() {
        loadGameState()
        checkWeeklyReset()
    }
    
    // MARK: - Challenge Data
    let challenges = [
        Challenge(
            category: "💝 Kjærlighetens gjerninger",
            text: "Skriv en hjertelig lapp til din partner om en egenskap du beundrer hos dem",
            description: "Ta deg tid til å reflektere over det som gjør din partner spesiell. Legg lappen et sted de vil finne den uventet."
        ),
        Challenge(
            category: "🏠 Hjemmeharmoni",
            text: "Gjør en husoppgave som partneren din vanligvis tar seg av",
            description: "Legg merke til noe partneren din vanligvis tar seg av og overrask dem ved å gjøre det selv med kjærlighet."
        ),
        Challenge(
            category: "🌱 Personlig vekst",
            text: "Lær noe nytt sammen i 30 minutter",
            description: "Velg et tema dere begge er nysgjerrige på - et språk, en ferdighet eller en hobby. Oppdag og voks sammen."
        ),
        Challenge(
            category: "💫 Kvalitetstid",
            text: "Legg bort alle enheter i en time og fokuser kun på hverandre",
            description: "Skap et hellig rom for ekte forbindelse. Snakk, le, eller bare nyt å være til stede sammen."
        ),
        Challenge(
            category: "🌟 Takknemlighet",
            text: "Del tre spesifikke ting du er takknemlig for ved din partner i dag",
            description: "Uttrykk ekte takknemlighet for både store og små ting. Vær spesifikk om hvordan de gjør livet ditt bedre."
        ),
        Challenge(
            category: "🎨 Kreativt uttrykk",
            text: "Skap noe sammen - kunst, musikk, matlaging eller bygging",
            description: "Engasjer kreativiteten deres som et team. Gleden ligger i prosessen med å skape noe vakkert sammen."
        ),
        Challenge(
            category: "🌍 Eventyr",
            text: "Utforsk et nytt sted i området deres sammen",
            description: "Besøk en park, restaurant eller et nabolag dere aldri har vært i. Eventyr krever ikke å reise langt."
        ),
        Challenge(
            category: "💪 Velvære",
            text: "Gjør en fysisk aktivitet sammen i 20 minutter",
            description: "Ta en spasertur, dans, strekk dere ut eller tren sammen. Støtt hverandres helse og energi."
        ),
        Challenge(
            category: "🎯 Drømmer",
            text: "Diskuter ett mål hver av dere ønsker å oppnå i år",
            description: "Del deres ambisjoner og tenk sammen om hvordan dere kan støtte hverandre i å oppnå dem."
        ),
        Challenge(
            category: "🤝 Tjeneste",
            text: "Gjør noe snilt for noen andre sammen",
            description: "Hjelp en nabo, vær frivillig, eller gjør en tilfeldig snill handling. Styrk båndet deres gjennom å gi."
        ),
        Challenge(
            category: "💝 Romantikk",
            text: "Planlegg en overraskende mini-date hjemme",
            description: "Skap et spesielt øyeblikk - middag med levende lys, piknik i stua, eller stjernekikking. Romantikk ligger i omtankefullheten."
        ),
        Challenge(
            category: "🗣️ Kommunikasjon",
            text: "Ha en samtale om deres favoritt minner sammen",
            description: "Minnes spesielle øyeblikk dere har delt. Gjenopplev gleden og styrk den emosjonelle forbindelsen."
        ),
        Challenge(
            category: "🌱 Vekst",
            text: "Lær hverandre noe dere kan gjøre",
            description: "Del ferdighetene og kunnskapen deres. Lær av hverandre og sett pris på deres unike talenter."
        ),
        Challenge(
            category: "🎉 Feiring",
            text: "Feir en liten seier eller prestasjon fra denne uken",
            description: "Anerkjenn og feir hverandres suksesser, uansett hvor små. Hver seier fortjener anerkjennelse."
        ),
        Challenge(
            category: "🌸 Oppmerksomhet",
            text: "Øv takknemlighetsmeditering sammen i 10 minutter",
            description: "Sitt stille sammen og reflekter over det dere er takknemlige for. Avslutt med å dele tankene deres med hverandre."
        )
    ]
    
    // MARK: - Core Game Logic
    
    func getDailyChallenge() -> Challenge {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return challenges[dayOfYear % challenges.count]
    }
    
    func acceptChallenge() {
        challengeAccepted = true
        saveGameState()
    }
    
    func markCompleted() {
        let today = todayString()
        
        // Check if already completed today
        if lastCompletedDate == today {
            return
        }
        
        // Update streak
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            let yesterdayString = dateFormatter.string(from: yesterday)
            if lastCompletedDate == yesterdayString {
                dailyStreak += 1
            } else {
                dailyStreak = 1
            }
        } else {
            dailyStreak = 1
        }
        
        // Calculate score
        let currentChallenge = getDailyChallenge()
        let baseScore = getCategoryScore(currentChallenge.category)
        let streakBonus = min(dailyStreak * 2, 20)
        let totalScoreEarned = baseScore + streakBonus
        
        // Update counters
        totalChallenges += 1
        weeklyCompleted += 1
        totalScore += totalScoreEarned
        lastCompletedDate = today
        todayCompleted = true
        challengeAccepted = false
        
        // Log the action
        let actionEntry = ActionEntry(
            date: Date(),
            challenge: currentChallenge.text,
            category: currentChallenge.category,
            baseScore: baseScore,
            streakBonus: streakBonus,
            totalScore: totalScoreEarned,
            streakDay: dailyStreak
        )
        
        actionLog.insert(actionEntry, at: 0)
        if actionLog.count > 50 {
            actionLog = Array(actionLog.prefix(50))
        }
        
        // Update category stats
        categoryStats[currentChallenge.category, default: 0] += 1
        
        // Check achievements
        checkAchievements()
        
        // Save state
        saveGameState()
        
        // Show celebration
        showingCelebration = true
    }
    
    func getNewChallenge() -> Challenge {
        var newChallenge: Challenge
        let currentChallenge = getDailyChallenge()
        
        repeat {
            newChallenge = challenges.randomElement() ?? challenges[0]
        } while newChallenge.id == currentChallenge.id && challenges.count > 1
        
        challengeAccepted = false
        saveGameState()
        return newChallenge
    }
    
    func getCategoryScore(_ category: String) -> Int {
        let scoreMap: [String: Int] = [
            "💝 Kjærlighetens gjerninger": 15,
            "🏠 Hjemmeharmoni": 10,
            "🌱 Personlig vekst": 20,
            "💫 Kvalitetstid": 15,
            "🌟 Takknemlighet": 12,
            "🎨 Kreativt uttrykk": 18,
            "🌍 Eventyr": 16,
            "💪 Velvære": 14,
            "🎯 Drømmer": 20,
            "🤝 Tjeneste": 18,
            "💝 Romantikk": 15,
            "🗣️ Kommunikasjon": 16,
            "🌱 Vekst": 20,
            "🎉 Feiring": 12,
            "🌸 Oppmerksomhet": 14
        ]
        return scoreMap[category] ?? 10
    }
    
    // MARK: - Achievements System
    
    private func checkAchievements() {
        let allAchievements = [
            Achievement(
                id: "first_step",
                title: "Første skritt",
                description: "Fullført din første utfordring",
                icon: "🌟",
                unlockedDate: nil
            ),
            Achievement(
                id: "week_warrior",
                title: "Ukens helt",
                description: "Fullført 7 utfordringer på en uke",
                icon: "🏆",
                unlockedDate: nil
            ),
            Achievement(
                id: "streak_master",
                title: "Rekkemester",
                description: "Oppnådd 7 dagers rekke",
                icon: "🔥",
                unlockedDate: nil
            ),
            Achievement(
                id: "love_expert",
                title: "Kjærlighetsekspert",
                description: "Fullført 5 kjærlighetsutfordringer",
                icon: "💕",
                unlockedDate: nil
            ),
            Achievement(
                id: "growth_guru",
                title: "Vekstguru",
                description: "Fullført 5 personlig vekst utfordringer",
                icon: "🌱",
                unlockedDate: nil
            ),
            Achievement(
                id: "hundred_club",
                title: "100-klubben",
                description: "Oppnådd 100 totale poeng",
                icon: "💯",
                unlockedDate: nil
            ),
            Achievement(
                id: "dedication",
                title: "Dedikasjon",
                description: "Fullført 30 utfordringer totalt",
                icon: "🎖️",
                unlockedDate: nil
            ),
            Achievement(
                id: "five_hundred",
                title: "Poengmester",
                description: "Oppnådd 500 totale poeng",
                icon: "👑",
                unlockedDate: nil
            )
        ]
        
        for achievement in allAchievements {
            let shouldUnlock = switch achievement.id {
            case "first_step": totalChallenges >= 1
            case "week_warrior": weeklyCompleted >= 7
            case "streak_master": dailyStreak >= 7
            case "love_expert": (categoryStats["💝 Kjærlighetens gjerninger"] ?? 0) >= 5
            case "growth_guru": (categoryStats["🌱 Personlig vekst"] ?? 0) >= 5
            case "hundred_club": totalScore >= 100
            case "dedication": totalChallenges >= 30
            case "five_hundred": totalScore >= 500
            default: false
            }
            
            if shouldUnlock && !achievements.contains(where: { $0.id == achievement.id }) {
                let unlockedAchievement = Achievement(
                    id: achievement.id,
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    unlockedDate: Date()
                )
                achievements.append(unlockedAchievement)
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveGameState() {
        let defaults = UserDefaults.standard
        defaults.set(dailyStreak, forKey: "dailyStreak")
        defaults.set(totalChallenges, forKey: "totalChallenges")
        defaults.set(weeklyCompleted, forKey: "weeklyCompleted")
        defaults.set(totalScore, forKey: "totalScore")
        defaults.set(challengeAccepted, forKey: "challengeAccepted")
        defaults.set(lastCompletedDate, forKey: "lastCompletedDate")
        defaults.set(lastWeeklyReset, forKey: "lastWeeklyReset")
        
        if let actionLogData = try? JSONEncoder().encode(actionLog) {
            defaults.set(actionLogData, forKey: "actionLog")
        }
        
        if let categoryStatsData = try? JSONEncoder().encode(categoryStats) {
            defaults.set(categoryStatsData, forKey: "categoryStats")
        }
        
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            defaults.set(achievementsData, forKey: "achievements")
        }
    }
    
    private func loadGameState() {
        let defaults = UserDefaults.standard
        dailyStreak = defaults.integer(forKey: "dailyStreak")
        totalChallenges = defaults.integer(forKey: "totalChallenges")
        weeklyCompleted = defaults.integer(forKey: "weeklyCompleted")
        totalScore = defaults.integer(forKey: "totalScore")
        challengeAccepted = defaults.bool(forKey: "challengeAccepted")
        lastCompletedDate = defaults.string(forKey: "lastCompletedDate") ?? ""
        lastWeeklyReset = defaults.string(forKey: "lastWeeklyReset") ?? ""
        
        if let actionLogData = defaults.data(forKey: "actionLog"),
           let decodedActionLog = try? JSONDecoder().decode([ActionEntry].self, from: actionLogData) {
            actionLog = decodedActionLog
        }
        
        if let categoryStatsData = defaults.data(forKey: "categoryStats"),
           let decodedCategoryStats = try? JSONDecoder().decode([String: Int].self, from: categoryStatsData) {
            categoryStats = decodedCategoryStats
        }
        
        if let achievementsData = defaults.data(forKey: "achievements"),
           let decodedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = decodedAchievements
        }
        
        // Check if today is completed
        todayCompleted = lastCompletedDate == todayString()
    }
    
    private func checkWeeklyReset() {
        let today = Date()
        let todayString = dateFormatter.string(from: today)
        let weekday = Calendar.current.component(.weekday, from: today)
        
        // Reset on Sunday (weekday == 1)
        if weekday == 1 && lastWeeklyReset != todayString {
            weeklyCompleted = 0
            lastWeeklyReset = todayString
            saveGameState()
        }
    }
    
    func getBestStreak() -> Int {
        let bestStreak = UserDefaults.standard.integer(forKey: "bestStreak")
        if dailyStreak > bestStreak {
            UserDefaults.standard.set(dailyStreak, forKey: "bestStreak")
            return dailyStreak
        }
        return bestStreak
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private func todayString() -> String {
        return dateFormatter.string(from: Date())
    }
}
