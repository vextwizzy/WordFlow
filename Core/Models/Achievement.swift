//
//  Achievement.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var title: String
    var descriptionText: String
    var iconName: String
    var xpReward: Int
    var requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    var category: AchievementCategory
    
    init(
        title: String,
        descriptionText: String,
        iconName: String,
        xpReward: Int,
        requirement: Int,
        category: AchievementCategory
    ) {
        self.id = UUID()
        self.title = title
        self.descriptionText = descriptionText
        self.iconName = iconName
        self.xpReward = xpReward
        self.requirement = requirement
        self.currentProgress = 0
        self.isUnlocked = false
        self.unlockedAt = nil
        self.category = category
    }
    
    var progress: Double {
        guard requirement > 0 else { return 1.0 }
        return min(Double(currentProgress) / Double(requirement), 1.0)
    }
    
    func updateProgress(_ value: Int) -> Bool {
        currentProgress = value
        
        if !isUnlocked && currentProgress >= requirement {
            isUnlocked = true
            unlockedAt = Date()
            return true // Achievement unlocked!
        }
        return false
    }
}

enum AchievementCategory: String, Codable {
    case words = "Words"
    case streak = "Streak"
    case quiz = "Quiz"
    case time = "Time"
    case level = "Level"
}

// Predefined achievements
extension Achievement {
    static let predefinedAchievements: [(title: String, description: String, icon: String, xp: Int, requirement: Int, category: AchievementCategory)] = [
        // Words
        ("First Steps", "Learn your first word", "star.fill", 10, 1, .words),
        ("Word Explorer", "Learn 10 words", "book.fill", 50, 10, .words),
        ("Vocabulary Builder", "Learn 50 words", "books.vertical.fill", 100, 50, .words),
        ("Word Master", "Learn 100 words", "graduationcap.fill", 200, 100, .words),
        ("Polyglot", "Learn 500 words", "globe", 500, 500, .words),
        ("Dictionary", "Learn 1000 words", "text.book.closed.fill", 1000, 1000, .words),
        
        // Streak
        ("Getting Started", "Study for 3 days in a row", "flame.fill", 30, 3, .streak),
        ("Committed", "Study for 7 days in a row", "flame.fill", 100, 7, .streak),
        ("Dedicated", "Study for 30 days in a row", "flame.fill", 300, 30, .streak),
        ("Unstoppable", "Study for 100 days in a row", "flame.fill", 1000, 100, .streak),
        
        // Quiz
        ("Quiz Beginner", "Complete 5 quizzes", "questionmark.circle.fill", 25, 5, .quiz),
        ("Quiz Expert", "Complete 20 quizzes", "checkmark.circle.fill", 100, 20, .quiz),
        ("Perfect Score", "Get 100% on a quiz", "star.circle.fill", 50, 1, .quiz),
        
        // Time
        ("Study Session", "Study for 10 minutes", "clock.fill", 20, 10, .time),
        ("Marathon", "Study for 1 hour total", "timer", 100, 60, .time),
        
        // Level
        ("Level 5", "Reach level 5", "5.circle.fill", 50, 5, .level),
        ("Level 10", "Reach level 10", "1.circle.fill", 100, 10, .level),
        ("Level 20", "Reach level 20", "crown.fill", 200, 20, .level)
    ]
}
