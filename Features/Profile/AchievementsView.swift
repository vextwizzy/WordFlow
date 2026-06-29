//
//  AchievementsView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    let achievements: [Achievement]
    @State private var selectedCategory: AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats header
                    statsHeader
                    
                    // Category filter
                    categoryFilter
                    
                    // Achievements list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAchievements.sorted(by: { 
                                if $0.isUnlocked != $1.isUnlocked {
                                    return $0.isUnlocked
                                }
                                return $0.progress > $1.progress
                            })) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        GlassCard {
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Unlocked")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Divider()
                    .frame(height: 50)
                    .background(.white.opacity(0.3))
                
                VStack(spacing: 8) {
                    Text("\(achievements.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Divider()
                    .frame(height: 50)
                    .background(.white.opacity(0.3))
                
                VStack(spacing: 8) {
                    CircularProgressBar(
                        progress: Double(unlockedCount) / Double(achievements.count),
                        size: 60,
                        lineWidth: 6,
                        gradient: .goldGradient
                    )
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach([AchievementCategory.words, .streak, .quiz, .time, .level], id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? 
                              LinearGradient.goldGradient : 
                              LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(achievement.title)
                        .font(.bodyLarge)
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text(achievement.descriptionText)
                        .font(.bodySmall)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                    
                    if achievement.isUnlocked {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.success)
                            
                            if let unlockedDate = achievement.unlockedAt {
                                Text("Unlocked \(unlockedDate, style: .relative) ago")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(achievement.currentProgress) / \(achievement.requirement)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            ProgressBar(
                                progress: achievement.progress,
                                height: 6,
                                foregroundGradient: .brandGradient
                            )
                        }
                    }
                }
                
                Spacer()
                
                // XP Badge
                if achievement.isUnlocked {
                    XPBadge(xp: achievement.xpReward, size: .small)
                } else {
                    Text("+\(achievement.xpReward)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(16)
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodySmall)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? LinearGradient.brandGradient : LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AchievementsView(achievements: [
        Achievement(title: "First Steps", descriptionText: "Learn your first word", iconName: "star.fill", xpReward: 10, requirement: 1, category: .words),
        Achievement(title: "Word Master", descriptionText: "Learn 100 words", iconName: "graduationcap.fill", xpReward: 200, requirement: 100, category: .words)
    ])
}
