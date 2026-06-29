//
//  UserProfile.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var level: Int
    var xp: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    var totalWordsLearned: Int
    var totalStudyTime: TimeInterval
    var isPremium: Bool
    var createdAt: Date
    var dailyGoal: Int
    var notificationTime: Date?
    var notificationsEnabled: Bool
    
    @Relationship(deleteRule: .cascade) var achievements: [Achievement]
    @Relationship(deleteRule: .cascade) var studySessions: [StudySession]
    @Relationship(deleteRule: .cascade) var dailyStreaks: [DailyStreak]
    
    init(
        name: String,
        email: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.level = 1
        self.xp = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastStudyDate = nil
        self.totalWordsLearned = 0
        self.totalStudyTime = 0
        self.isPremium = false
        self.createdAt = Date()
        self.dailyGoal = 50
        self.notificationTime = nil
        self.notificationsEnabled = true
        self.achievements = []
        self.studySessions = []
        self.dailyStreaks = []
    }
    
    // XP needed for next level
    var xpForNextLevel: Int {
        return level * 100
    }
    
    // Progress to next level (0.0 to 1.0)
    var levelProgress: Double {
        let xpInCurrentLevel = xp % xpForNextLevel
        return Double(xpInCurrentLevel) / Double(xpForNextLevel)
    }
    
    // Add XP and check for level up
    func addXP(_ amount: Int) -> Bool {
        xp += amount
        
        if xp >= xpForNextLevel {
            level += 1
            return true // Leveled up
        }
        return false
    }
    
    // Update streak
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastStudy = lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastStudy)
            let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Продолжаем серию
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else if daysDifference > 1 {
                // Серия прервана
                currentStreak = 1
            }
            // daysDifference == 0 означает, что уже учились сегодня
        } else {
            // Первый день обучения
            currentStreak = 1
            longestStreak = 1
        }
        
        lastStudyDate = Date()
    }
    
    // Check if streak is at risk
    var streakAtRisk: Bool {
        guard let lastStudy = lastStudyDate else { return true }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStudyDay = calendar.startOfDay(for: lastStudy)
        let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        return daysDifference >= 1
    }
}
