//
//  DataManager.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation
import SwiftData

@Observable
final class DataManager {
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() {
        let schema = Schema([
            Word.self,
            UserProfile.self,
            Achievement.self,
            DailyStreak.self,
            Quiz.self,
            QuizSession.self,
            StudySession.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - User Profile
    
    func getUserProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try? modelContext.fetch(descriptor)
        return profiles?.first
    }
    
    func createUserProfile(name: String) -> UserProfile {
        let profile = UserProfile(name: name)
        
        // Create predefined achievements
        for achievementData in Achievement.predefinedAchievements {
            let achievement = Achievement(
                title: achievementData.title,
                descriptionText: achievementData.description,
                iconName: achievementData.icon,
                xpReward: achievementData.xp,
                requirement: achievementData.requirement,
                category: achievementData.category
            )
            profile.achievements.append(achievement)
        }
        
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }
    
    // MARK: - Words
    
    func getAllWords() -> [Word] {
        let descriptor = FetchDescriptor<Word>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getWordsForStudy(limit: Int, isPremium: Bool) -> [Word] {
        let dailyLimit = isPremium ? Int.max : 50
        let actualLimit = min(limit, dailyLimit)
        
        var descriptor = FetchDescriptor<Word>(
            predicate: #Predicate { word in
                !word.isLearned || word.shouldReview
            },
            sortBy: [SortDescriptor(\.lastReviewed, order: .forward)]
        )
        descriptor.fetchLimit = actualLimit
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addWord(_ word: Word) {
        modelContext.insert(word)
        try? modelContext.save()
    }
    
    func updateWord(_ word: Word) {
        try? modelContext.save()
    }
    
    // MARK: - Study Session
    
    func createStudySession() -> StudySession {
        let session = StudySession()
        modelContext.insert(session)
        try? modelContext.save()
        return session
    }
    
    func endStudySession(_ session: StudySession, profile: UserProfile) {
        session.endSession()
        
        // Update profile statistics
        profile.totalStudyTime += session.duration
        profile.updateStreak()
        
        // Update today's streak
        let today = getTodayStreak(for: profile)
        today.addStudyTime(session.duration)
        today.wordsStudied += session.wordsStudiedIds.count
        today.xpEarned += session.xpEarned
        
        try? modelContext.save()
    }
    
    // MARK: - Daily Streak
    
    func getTodayStreak(for profile: UserProfile) -> DailyStreak {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let existingStreak = profile.dailyStreaks.first(where: { 
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            return existingStreak
        }
        
        let newStreak = DailyStreak(date: today)
        profile.dailyStreaks.append(newStreak)
        try? modelContext.save()
        return newStreak
    }
    
    // MARK: - Achievements
    
    func checkAndUnlockAchievements(for profile: UserProfile) -> [Achievement] {
        var unlockedAchievements: [Achievement] = []
        
        for achievement in profile.achievements where !achievement.isUnlocked {
            var shouldUpdate = false
            
            switch achievement.category {
            case .words:
                shouldUpdate = achievement.updateProgress(profile.totalWordsLearned)
            case .streak:
                shouldUpdate = achievement.updateProgress(profile.currentStreak)
            case .level:
                shouldUpdate = achievement.updateProgress(profile.level)
            case .time:
                let totalMinutes = Int(profile.totalStudyTime / 60)
                shouldUpdate = achievement.updateProgress(totalMinutes)
            case .quiz:
                let quizSessions = try? modelContext.fetch(FetchDescriptor<QuizSession>())
                let totalQuizzes = quizSessions?.count ?? 0
                shouldUpdate = achievement.updateProgress(totalQuizzes)
            }
            
            if shouldUpdate {
                unlockedAchievements.append(achievement)
                profile.addXP(achievement.xpReward)
            }
        }
        
        try? modelContext.save()
        return unlockedAchievements
    }
    
    // MARK: - Quiz
    
    func createQuizSession() -> QuizSession {
        let session = QuizSession()
        modelContext.insert(session)
        try? modelContext.save()
        return session
    }
    
    func generateQuizzes(from words: [Word], count: Int) -> [Quiz] {
        let selectedWords = Array(words.shuffled().prefix(count))
        var quizzes: [Quiz] = []
        
        for word in selectedWords {
            let quizType = QuizType.allCases.randomElement() ?? .translation
            let quiz = createQuiz(for: word, type: quizType, allWords: words)
            quizzes.append(quiz)
        }
        
        return quizzes
    }
    
    private func createQuiz(for word: Word, type: QuizType, allWords: [Word]) -> Quiz {
        var question = ""
        var options: [String] = []
        var correctAnswer = ""
        
        switch type {
        case .translation:
            question = "What does '\(word.english)' mean?"
            correctAnswer = word.translation
            
            // Generate wrong options
            let wrongWords = allWords.filter { $0.id != word.id }.shuffled().prefix(3)
            options = wrongWords.map { $0.translation } + [correctAnswer]
            options.shuffle()
            
        case .fillInBlank:
            if !word.example.isEmpty {
                question = word.example.replacingOccurrences(of: word.english, with: "____", options: [.caseInsensitive])
                correctAnswer = word.english
                
                let wrongWords = allWords.filter { $0.id != word.id }.shuffled().prefix(3)
                options = wrongWords.map { $0.english } + [correctAnswer]
                options.shuffle()
            } else {
                // Fallback to translation
                question = "What does '\(word.english)' mean?"
                correctAnswer = word.translation
                let wrongWords = allWords.filter { $0.id != word.id }.shuffled().prefix(3)
                options = wrongWords.map { $0.translation } + [correctAnswer]
                options.shuffle()
            }
            
        case .multipleChoice:
            question = "Choose the correct translation for '\(word.translation)'"
            correctAnswer = word.english
            
            let wrongWords = allWords.filter { $0.id != word.id }.shuffled().prefix(3)
            options = wrongWords.map { $0.english } + [correctAnswer]
            options.shuffle()
            
        case .listening:
            question = "Listen and choose the correct word"
            correctAnswer = word.english
            
            let wrongWords = allWords.filter { $0.id != word.id }.shuffled().prefix(3)
            options = wrongWords.map { $0.english } + [correctAnswer]
            options.shuffle()
        }
        
        let quiz = Quiz(
            wordId: word.id,
            wordEnglish: word.english,
            questionType: type,
            question: question,
            options: options,
            correctAnswer: correctAnswer
        )
        
        modelContext.insert(quiz)
        try? modelContext.save()
        
        return quiz
    }
    
    // MARK: - Statistics
    
    func getWeeklyStats() -> [DailyStreak] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let descriptor = FetchDescriptor<DailyStreak>(
            predicate: #Predicate { streak in
                streak.date >= weekAgo
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Sample Data
    
    func loadSampleWords() {
        let sampleWords = [
            ("Journey", "/ˈdʒɜːrni/", "Путешествие", "A journey is when you travel from one place to another.", "I went on a long journey across Europe.", "beginner"),
            ("Courage", "/ˈkʌrɪdʒ/", "Смелость", "The ability to do something that frightens you.", "It takes courage to speak in public.", "intermediate"),
            ("Wisdom", "/ˈwɪzdəm/", "Мудрость", "The quality of having experience and good judgment.", "With age comes wisdom.", "intermediate"),
            ("Adventure", "/ədˈventʃər/", "Приключение", "An exciting experience or journey.", "Life is an adventure.", "beginner"),
            ("Harmony", "/ˈhɑːrməni/", "Гармония", "A state of peaceful agreement and cooperation.", "They lived in harmony with nature.", "advanced")
        ]
        
        for (english, transcription, translation, explanation, example, difficulty) in sampleWords {
            let difficultyLevel: DifficultyLevel
            switch difficulty {
            case "beginner": difficultyLevel = .beginner
            case "intermediate": difficultyLevel = .intermediate
            case "advanced": difficultyLevel = .advanced
            default: difficultyLevel = .beginner
            }
            
            let word = Word(
                english: english,
                transcription: transcription,
                translation: translation,
                explanation: explanation,
                example: example,
                difficulty: difficultyLevel
            )
            addWord(word)
        }
    }
}

extension QuizType: CaseIterable {}
