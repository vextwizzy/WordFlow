//
//  ProfileViewModel.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

@Observable
final class ProfileViewModel {
    private let dataManager: DataManager
    var profile: UserProfile
    
    init(dataManager: DataManager, profile: UserProfile) {
        self.dataManager = dataManager
        self.profile = profile
    }
    
    var memberSinceText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: profile.createdAt)
    }
    
    var xpToNextLevel: Int {
        let xpForNext = profile.xpForNextLevel
        let currentLevelXP = profile.xp % xpForNext
        return xpForNext - currentLevelXP
    }
    
    var studyTimeText: String {
        let hours = Int(profile.totalStudyTime / 3600)
        let minutes = Int((profile.totalStudyTime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var unlockedAchievementsCount: Int {
        profile.achievements.filter { $0.isUnlocked }.count
    }
    
    var recentAchievements: [Achievement] {
        let unlocked = profile.achievements.filter { $0.isUnlocked }
            .sorted { $0.unlockedAt ?? Date.distantPast > $1.unlockedAt ?? Date.distantPast }
            .prefix(3)
        
        let inProgress = profile.achievements.filter { !$0.isUnlocked && $0.currentProgress > 0 }
            .sorted { $0.progress > $1.progress }
            .prefix(3)
        
        return Array((unlocked + inProgress).prefix(6))
    }
    
    var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }.reversed()
    }
    
    func hasStudiedOn(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return profile.dailyStreaks.contains { streak in
            calendar.isDate(streak.date, inSameDayAs: date) && streak.wordsStudied > 0
        }
    }
    
    func dayInitial(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
