//
//  AppConstants.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

enum AppConstants {
    // App Info
    static let appName = "WordFlow"
    static let version = "1.0.0"
    
    // Study Limits
    static let freeDailyLimit = 50
    static let premiumDailyLimit = Int.max
    
    // XP Values
    static let xpPerWord = 10
    static let xpPerCorrectSwipe = 10
    static let xpPerWrongSwipe = 5
    static let xpPerQuizCorrect = 20
    
    // Quiz Settings
    static let quizInterval = 20 // Show quiz every 20 swipes
    static let quizQuestionsCount = 5
    
    // Gamification
    static let xpPerLevel = 100
    
    // Review Intervals (in days)
    static let reviewIntervalEasy = 7
    static let reviewIntervalMedium = 3
    static let reviewIntervalHard = 1
    
    // URLs
    static let privacyPolicyURL = "https://wordflow.app/privacy"
    static let termsOfServiceURL = "https://wordflow.app/terms"
    static let supportEmail = "support@wordflow.app"
}
