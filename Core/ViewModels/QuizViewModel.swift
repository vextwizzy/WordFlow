//
//  QuizViewModel.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftUI

@Observable
final class QuizViewModel {
    private let dataManager: DataManager
    var profile: UserProfile
    private let words: [Word]
    
    var quizzes: [Quiz] = []
    var currentQuizIndex = 0
    var selectedAnswer: String?
    var showResult = false
    var isCompleted = false
    
    var correctAnswers = 0
    var wrongAnswers = 0
    var xpEarned = 0
    
    private var quizSession: QuizSession?
    
    init(dataManager: DataManager, profile: UserProfile, words: [Word]) {
        self.dataManager = dataManager
        self.profile = profile
        self.words = words
    }
    
    var progress: Double {
        guard !quizzes.isEmpty else { return 0 }
        return Double(currentQuizIndex) / Double(quizzes.count)
    }
    
    var scorePercentage: Double {
        let total = correctAnswers + wrongAnswers
        guard total > 0 else { return 0 }
        return Double(correctAnswers) / Double(total) * 100
    }
    
    var isPerfect: Bool {
        return correctAnswers == quizzes.count && wrongAnswers == 0
    }
    
    // MARK: - Generate Quizzes
    
    func generateQuizzes() async {
        quizSession = dataManager.createQuizSession()
        
        await MainActor.run {
            // Generate 5 quiz questions
            let quizCount = min(5, words.count)
            quizzes = dataManager.generateQuizzes(from: words, count: quizCount)
            
            quizSession?.totalQuestions = quizzes.count
            
            // Save quiz IDs to session
            quizSession?.quizIds = quizzes.map { $0.id }
        }
    }
    
    // MARK: - Select Answer
    
    func selectAnswer(_ answer: String) {
        guard !showResult else { return }
        
        selectedAnswer = answer
        showResult = true
        
        let currentQuiz = quizzes[currentQuizIndex]
        currentQuiz.submitAnswer(answer)
        
        let isCorrect = answer == currentQuiz.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
            quizSession?.correctAnswers += 1
            HapticService.shared.correctAnswer()
            
            // Award XP for correct answer
            let xp = 20
            xpEarned += xp
            _ = profile.addXP(xp)
            quizSession?.xpEarned += xp
            
        } else {
            wrongAnswers += 1
            quizSession?.wrongAnswers += 1
            HapticService.shared.wrongAnswer()
        }
        
        // Update today's streak
        let todayStreak = dataManager.getTodayStreak(for: profile)
        todayStreak.addQuiz()
    }
    
    // MARK: - Next Question
    
    func nextQuestion() {
        if currentQuizIndex < quizzes.count - 1 {
            withAnimation(.smooth) {
                currentQuizIndex += 1
                selectedAnswer = nil
                showResult = false
            }
        } else {
            completeQuiz()
        }
    }
    
    // MARK: - Complete Quiz
    
    private func completeQuiz() {
        withAnimation(.smooth) {
            isCompleted = true
        }
        
        quizSession?.completeSession()
        
        // Check for achievements
        _ = dataManager.checkAndUnlockAchievements(for: profile)
        
        // Check for perfect score achievement
        if isPerfect {
            if let perfectAchievement = profile.achievements.first(where: { 
                $0.title == "Perfect Score" && !$0.isUnlocked 
            }) {
                _ = perfectAchievement.updateProgress(1)
                _ = profile.addXP(perfectAchievement.xpReward)
                NotificationService.shared.notifyAchievementUnlocked(
                    title: perfectAchievement.title,
                    xp: perfectAchievement.xpReward
                )
            }
        }
    }
}
