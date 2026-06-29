//
//  StatisticsView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel
    @State private var selectedTimeRange: TimeRange = .week
    
    init(dataManager: DataManager, profile: UserProfile) {
        _viewModel = State(initialValue: StatisticsViewModel(dataManager: dataManager, profile: profile))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time range selector
                        timeRangeSelector
                        
                        // Summary cards
                        summaryCards
                        
                        // Words learned chart
                        wordsLearnedChart
                        
                        // Study time chart
                        studyTimeChart
                        
                        // Accuracy chart
                        accuracyChart
                        
                        // Category breakdown
                        categoryBreakdown
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadStatistics(for: selectedTimeRange)
        }
    }
    
    // MARK: - Time Range Selector
    
    private var timeRangeSelector: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    selectedTimeRange = range
                    Task {
                        await viewModel.loadStatistics(for: range)
                    }
                }) {
                    Text(range.rawValue)
                        .font(.bodySmall)
                        .foregroundStyle(selectedTimeRange == range ? .white : .white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTimeRange == range ? 
                                      LinearGradient.brandGradient : 
                                      LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            SummaryCard(
                title: "Words",
                value: "\(viewModel.totalWords)",
                icon: "book.fill",
                gradient: .brandGradient
            )
            
            SummaryCard(
                title: "Study Time",
                value: viewModel.totalStudyTimeText,
                icon: "clock.fill",
                gradient: .successGradient
            )
            
            SummaryCard(
                title: "Accuracy",
                value: "\(Int(viewModel.accuracy * 100))%",
                icon: "target",
                gradient: .goldGradient
            )
            
            SummaryCard(
                title: "Avg/Day",
                value: "\(viewModel.averageWordsPerDay)",
                icon: "chart.line.uptrend.xyaxis",
                gradient: LinearGradient(
                    colors: [.info, .brandSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Words Learned Chart
    
    private var wordsLearnedChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Words Learned")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                Chart {
                    ForEach(viewModel.dailyStats, id: \.date) { stat in
                        BarMark(
                            x: .value("Date", stat.date, unit: .day),
                            y: .value("Words", stat.wordsStudied)
                        )
                        .foregroundStyle(LinearGradient.brandGradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day().month())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Study Time Chart
    
    private var studyTimeChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Study Time (minutes)")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                Chart {
                    ForEach(viewModel.dailyStats, id: \.date) { stat in
                        LineMark(
                            x: .value("Date", stat.date, unit: .day),
                            y: .value("Minutes", stat.studyTime / 60)
                        )
                        .foregroundStyle(.success)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", stat.date, unit: .day),
                            y: .value("Minutes", stat.studyTime / 60)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.success.opacity(0.3), .success.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day().month())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Accuracy Chart
    
    private var accuracyChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Learning Progress")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                HStack(spacing: 30) {
                    VStack(spacing: 12) {
                        CircularProgressBar(
                            progress: viewModel.accuracy,
                            size: 120,
                            lineWidth: 12,
                            gradient: .successGradient
                        )
                        
                        Text("Overall Accuracy")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(.success)
                                .frame(width: 12, height: 12)
                            
                            Text("Correct")
                                .font(.bodySmall)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(viewModel.totalCorrect)")
                                .font(.bodyRegular)
                                .bold()
                                .foregroundStyle(.white)
                        }
                        
                        HStack {
                            Circle()
                                .fill(.error)
                                .frame(width: 12, height: 12)
                            
                            Text("Wrong")
                                .font(.bodySmall)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(viewModel.totalWrong)")
                                .font(.bodyRegular)
                                .bold()
                                .foregroundStyle(.white)
                        }
                        
                        Divider()
                            .background(.white.opacity(0.3))
                        
                        HStack {
                            Text("Total")
                                .font(.bodySmall)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(viewModel.totalCorrect + viewModel.totalWrong)")
                                .font(.bodyRegular)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Category Breakdown
    
    private var categoryBreakdown: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Categories")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                if !viewModel.categoryData.isEmpty {
                    ForEach(viewModel.categoryData, id: \.category) { data in
                        VStack(spacing: 8) {
                            HStack {
                                Text(data.category)
                                    .font(.bodyRegular)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text("\(data.count) words")
                                    .font(.bodySmall)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            ProgressBar(
                                progress: data.percentage,
                                height: 8,
                                foregroundGradient: .brandGradient
                            )
                        }
                    }
                } else {
                    Text("No data available")
                        .font(.bodyRegular)
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(gradient)
                
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Time Range

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

#Preview {
    StatisticsView(
        dataManager: DataManager(),
        profile: UserProfile(name: "Test")
    )
}
