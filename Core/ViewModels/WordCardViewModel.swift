//
//  WordCardViewModel.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftUI

@Observable
final class WordCardViewModel {
    private let dataManager: DataManager
    var profile: UserProfile
    
    var words: [Word] = []
    var currentWordIndex = 0
    var dragOffset: CGSize = .zero
    var isLoading = false
    
    // Stats
    var wordsStudiedToday = 0
    var correctSwipes = 0
    var wrongSwipes = 0
    var totalSwipes = 0
    
    // UI States
    var showLevelUp = false
    var unlockedAchievement: Achievement?
    var shouldShowQuiz = false
    
    // Current study session
    private var currentSession: StudySession?
    
    init(dataManager: DataManager, profile: UserProfile) {
        self.dataManager = dataManager
        self.profile = profile
        
        // Start a new study session
        self.currentSession = dataManager.createStudySession()
        
        // Load today's stats
        let todayStreak = dataManager.getTodayStreak(for: profile)
        self.wordsStudiedToday = todayStreak.wordsStudied
    }
    
    // MARK: - Load Words
    
    func loadWords() async {
        isLoading = true
        
        await MainActor.run {
            let limit = profile.isPremium ? 100 : 50
            words = dataManager.getWordsForStudy(limit: limit, isPremium: profile.isPremium)
            
            // If no words, load sample words
            if words.isEmpty {
                dataManager.loadSampleWords()
                words = dataManager.getWordsForStudy(limit: limit, isPremium: profile.isPremium)
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Handle Swipe
    
    func handleSwipe(word: Word, knowIt: Bool) {
        totalSwipes += 1
        
        if knowIt {
            correctSwipes += 1
            word.swipedRight += 1
            
            // Mark as learned if swiped right multiple times
            if word.swipedRight >= 3 {
                word.isLearned = true
                profile.totalWordsLearned += 1
            }
        } else {
            wrongSwipes += 1
            word.swipedLeft += 1
        }
        
        // Update word
        word.swipeCount += 1
        word.lastReviewed = Date()
        word.nextReview = calculateNextReview(for: word)
        dataManager.updateWord(word)
        
        // Update session
        currentSession?.addWord(word.id)
        currentSession?.recordSwipe(isCorrect: knowIt)
        
        // Award XP
        let xpEarned = calculateXP(for: word, knowIt: knowIt)
        let leveledUp = profile.addXP(xpEarned)
        currentSession?.xpEarned += xpEarned
        
        // Update today's streak
        let todayStreak = dataManager.getTodayStreak(for: profile)
        todayStreak.addWord()
        todayStreak.addXP(xpEarned)
        wordsStudiedToday = todayStreak.wordsStudied
        
        // Check achievements
        let unlockedAchievements = dataManager.checkAndUnlockAchievements(for: profile)
        if let firstAchievement = unlockedAchievements.first {
            showAchievement(firstAchievement)
        }
        
        // Show level up
        if leveledUp {
            showLevelUpAnimation()
        }
        
        // Remove current word
        if !words.isEmpty {
            words.removeFirst()
        }
        
        // Check if should show quiz (every 20 swipes)
        if totalSwipes % 20 == 0 && totalSwipes > 0 {
            shouldShowQuiz = true
        }
    }
    
    // MARK: - Calculate XP
    
    private func calculateXP(for word: Word, knowIt: Bool) -> Int {
        let baseXP = knowIt ? 10 : 5
        let multiplier = word.difficulty.xpMultiplier
        return Int(Double(baseXP) * multiplier)
    }
    
    // MARK: - Calculate Next Review
    
    private func calculateNextReview(for word: Word) -> Date {
        let masteryLevel = word.masteryLevel
        var daysUntilReview = 1
        
        if masteryLevel >= 0.8 {
            daysUntilReview = 7
        } else if masteryLevel >= 0.6 {
            daysUntilReview = 3
        } else if masteryLevel >= 0.4 {
            daysUntilReview = 1
        }
        
        return Calendar.current.date(byAdding: .day, value: daysUntilReview, to: Date()) ?? Date()
    }
    
    // MARK: - Quiz
    
    func startQuiz() {
        shouldShowQuiz = false
        // Quiz navigation will be handled by parent view
    }
    
    // MARK: - Level Up
    
    private func showLevelUpAnimation() {
        withAnimation(.smooth) {
            showLevelUp = true
        }
        
        HapticService.shared.levelUp()
        NotificationService.shared.notifyLevelUp(level: profile.level)
    }
    
    func dismissLevelUp() {
        withAnimation(.smooth) {
            showLevelUp = false
        }
    }
    
    // MARK: - Achievement
    
    private func showAchievement(_ achievement: Achievement) {
        withAnimation(.smooth) {
            unlockedAchievement = achievement
        }
        
        HapticService.shared.achievementUnlocked()
        NotificationService.shared.notifyAchievementUnlocked(
            title: achievement.title,
            xp: achievement.xpReward
        )
    }
    
    func dismissAchievement() {
        withAnimation(.smooth) {
            unlockedAchievement = nil
        }
    }
    
    // MARK: - End Session
    
    func endSession() {
        guard let session = currentSession else { return }
        dataManager.endStudySession(session, profile: profile)
    }
}
