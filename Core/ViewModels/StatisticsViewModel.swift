//
//  StatisticsViewModel.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

@Observable
final class StatisticsViewModel {
    private let dataManager: DataManager
    var profile: UserProfile
    
    var dailyStats: [DailyStreak] = []
    var totalWords = 0
    var totalStudyTime: TimeInterval = 0
    var totalCorrect = 0
    var totalWrong = 0
    var categoryData: [(category: String, count: Int, percentage: Double)] = []
    
    init(dataManager: DataManager, profile: UserProfile) {
        self.dataManager = dataManager
        self.profile = profile
    }
    
    var accuracy: Double {
        let total = totalCorrect + totalWrong
        guard total > 0 else { return 0 }
        return Double(totalCorrect) / Double(total)
    }
    
    var totalStudyTimeText: String {
        let hours = Int(totalStudyTime / 3600)
        let minutes = Int((totalStudyTime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var averageWordsPerDay: Int {
        guard !dailyStats.isEmpty else { return 0 }
        let total = dailyStats.reduce(0) { $0 + $1.wordsStudied }
        return total / dailyStats.count
    }
    
    // MARK: - Load Statistics
    
    func loadStatistics(for timeRange: TimeRange) async {
        await MainActor.run {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var startDate: Date
            
            switch timeRange {
            case .week:
                startDate = calendar.date(byAdding: .day, value: -7, to: today)!
            case .month:
                startDate = calendar.date(byAdding: .month, value: -1, to: today)!
            case .year:
                startDate = calendar.date(byAdding: .year, value: -1, to: today)!
            }
            
            // Get daily stats
            dailyStats = profile.dailyStreaks.filter { $0.date >= startDate }
                .sorted { $0.date < $1.date }
            
            // Fill in missing days with zero data
            var filledStats: [DailyStreak] = []
            var currentDate = startDate
            
            while currentDate <= today {
                if let existingStat = dailyStats.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    filledStats.append(existingStat)
                } else {
                    filledStats.append(DailyStreak(date: currentDate))
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            dailyStats = filledStats
            
            // Calculate totals
            totalWords = dailyStats.reduce(0) { $0 + $1.wordsStudied }
            totalStudyTime = dailyStats.reduce(0) { $0 + $1.studyTime }
            
            // Get all words and calculate accuracy
            let allWords = dataManager.getAllWords()
            totalCorrect = allWords.reduce(0) { $0 + $1.swipedRight }
            totalWrong = allWords.reduce(0) { $0 + $1.swipedLeft }
            
            // Calculate category breakdown
            calculateCategoryBreakdown(from: allWords)
        }
    }
    
    // MARK: - Calculate Category Breakdown
    
    private func calculateCategoryBreakdown(from words: [Word]) {
        var categoryCount: [String: Int] = [:]
        
        for word in words where word.isLearned {
            categoryCount[word.category, default: 0] += 1
        }
        
        let totalLearned = categoryCount.values.reduce(0, +)
        guard totalLearned > 0 else {
            categoryData = []
            return
        }
        
        categoryData = categoryCount.map { (category, count) in
            let percentage = Double(count) / Double(totalLearned)
            return (category: category, count: count, percentage: percentage)
        }
        .sorted { $0.count > $1.count }
    }
}
