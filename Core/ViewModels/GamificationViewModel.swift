//
//  GamificationViewModel.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

@Observable
final class GamificationViewModel {
    let dataManager: DataManager
    var profile: UserProfile
    
    init(dataManager: DataManager, profile: UserProfile) {
        self.dataManager = dataManager
        self.profile = profile
    }
    
    // MARK: - XP System
    
    static func calculateXP(
        for word: Word,
        isCorrect: Bool,
        streakMultiplier: Int = 0
    ) -> Int {
        let baseXP = isCorrect ? AppConstants.xpPerCorrectSwipe : AppConstants.xpPerWrongSwipe
        let difficultyMultiplier = word.difficulty.xpMultiplier
        
        // Streak bonus: +1 XP per streak day, max +10
        let streakBonus = min(streakMultiplier, 10)
        
        return Int((Double(baseXP) * difficultyMultiplier) + Double(streakBonus))
    }
    
    static func calculateQuizXP(isCorrect: Bool) -> Int {
        return isCorrect ? AppConstants.xpPerQuizCorrect : 0
    }
    
    // MARK: - Level System
    
    static func xpForLevel(_ level: Int) -> Int {
        return level * AppConstants.xpPerLevel
    }
    
    static func totalXpForLevel(_ level: Int) -> Int {
        return (1...level).reduce(0) { $0 + xpForLevel($1) }
    }
    
    var nextLevelXP: Int {
        GamificationViewModel.xpForLevel(profile.level)
    }
    
    var currentLevelProgress: Double {
        let xpInCurrentLevel = profile.xp - GamificationViewModel.totalXpForLevel(profile.level - 1)
        let neededForNext = nextLevelXP
        guard neededForNext > 0 else { return 0 }
        return Double(xpInCurrentLevel) / Double(neededForNext)
    }
    
    // MARK: - Streak System
    
    var isStreakAtRisk: Bool {
        guard let lastStudy = profile.lastStudyDate else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastStudy)
    }
    
    var daysUntilStreakBreak: Int {
        guard let lastStudy = profile.lastStudyDate else { return 1 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStudyDay = calendar.startOfDay(for: lastStudy)
        let daysSinceStudy = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        if daysSinceStudy >= 1 {
            return 0 // Already broken
        }
        return 1 // Safe today
    }
    
    func checkStreakAndNotify() {
        if isStreakAtRisk && profile.currentStreak > 0 {
            NotificationService.shared.scheduleStreakReminder(
                currentStreak: profile.currentStreak
            )
        }
    }
    
    // MARK: - Achievement System
    
    static func checkBulkAchievements(
        for profile: UserProfile,
        dataManager: DataManager
    ) -> [Achievement] {
        return dataManager.checkAndUnlockAchievements(for: profile)
    }
    
    // MARK: - Daily Goals
    
    var dailyProgress: Double {
        let todayStreak = dataManager.getTodayStreak(for: profile)
        guard profile.dailyGoal > 0 else { return 0 }
        return Double(todayStreak.wordsStudied) / Double(profile.dailyGoal)
    }
    
    var isGoalAchieved: Bool {
        dailyProgress >= 1.0
    }
    
    // MARK: - Session Summary
    
    struct SessionSummary: Sendable {
        let duration: TimeInterval
        let wordsStudied: Int
        let correctAnswers: Int
        let wrongAnswers: Int
        let xpEarned: Int
        let newWordsLearned: Int
        let achievementsUnlocked: Int
        
        var accuracy: Double {
            let total = correctAnswers + wrongAnswers
            guard total > 0 else { return 0 }
            return Double(correctAnswers) / Double(total)
        }
        
        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            }
            return "\(seconds)s"
        }
    }
    
    func generateSessionSummary(from session: StudySession) -> SessionSummary {
        SessionSummary(
            duration: session.duration,
            wordsStudied: session.wordsStudiedIds.count,
            correctAnswers: session.correctSwipes,
            wrongAnswers: session.wrongSwipes,
            xpEarned: session.xpEarned,
            newWordsLearned: profile.totalWordsLearned,
            achievementsUnlocked: profile.achievements.filter { $0.isUnlocked }.count
        )
    }
    
    // MARK: - Motivational Messages
    
    static func motivationalMessage(for streak: Int, level: Int) -> String {
        switch streak {
        case 0:
            return "Start your learning journey today!"
        case 1:
            return "Great start! Come back tomorrow!"
        case 2...6:
            return "Keep it going! You're building a habit!"
        case 7...13:
            return "One week streak! You're unstoppable!"
        case 14...29:
            return "Two weeks of learning! Amazing dedication!"
        case 30...59:
            return "One month! You're a true learner!"
        case 60...99:
            return "Two months strong! Incredible consistency!"
        default:
            return "Legendary streak! You're a WordFlow master!"
        }
    }
}
