//
//  ProfileView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showPremium = false
    
    init(dataManager: DataManager, profile: UserProfile) {
        _viewModel = State(initialValue: ProfileViewModel(dataManager: dataManager, profile: profile))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with avatar and level
                        profileHeader
                        
                        // XP Progress
                        xpProgressSection
                        
                        // Stats Grid
                        statsGrid
                        
                        // Streak Section
                        streakSection
                        
                        // Achievements Preview
                        achievementsPreview
                        
                        // Premium CTA (if not premium)
                        if !viewModel.profile.isPremium {
                            premiumCTA
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(profile: viewModel.profile)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(achievements: viewModel.profile.achievements)
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar with level badge
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(LinearGradient.brandGradient)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(viewModel.profile.name.prefix(1).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    )
                
                LevelBadge(level: viewModel.profile.level, size: 36)
                    .offset(x: 8, y: 8)
            }
            
            // Name
            Text(viewModel.profile.name)
                .font(.title1)
                .foregroundStyle(.white)
            
            // Member since
            Text("Member since \(viewModel.memberSinceText)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - XP Progress
    
    private var xpProgressSection: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(viewModel.profile.level)")
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Text("\(viewModel.profile.xp) Total XP")
                            .font(.bodySmall)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    XPBadge(xp: viewModel.xpToNextLevel, size: .medium)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                        
                        Capsule()
                            .fill(LinearGradient.goldGradient)
                            .frame(width: geometry.size.width * viewModel.profile.levelProgress)
                    }
                }
                .frame(height: 12)
                
                Text("Next level: \(viewModel.xpToNextLevel) XP remaining")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(20)
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "book.fill",
                value: "\(viewModel.profile.totalWordsLearned)",
                label: "Words Learned",
                gradient: .brandGradient
            )
            
            StatCard(
                icon: "clock.fill",
                value: viewModel.studyTimeText,
                label: "Study Time",
                gradient: .successGradient
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(viewModel.profile.longestStreak)",
                label: "Best Streak",
                gradient: LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            StatCard(
                icon: "trophy.fill",
                value: "\(viewModel.unlockedAchievementsCount)",
                label: "Achievements",
                gradient: .goldGradient
            )
        }
    }
    
    // MARK: - Streak Section
    
    private var streakSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Current Streak")
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    StreakIndicator(streak: viewModel.profile.currentStreak, isCompact: true)
                }
                
                // Weekly streak visualization
                HStack(spacing: 8) {
                    ForEach(viewModel.last7Days, id: \.self) { day in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(viewModel.hasStudiedOn(day) ? 
                                      LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom) :
                                      LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(viewModel.dayInitial(day))
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                )
                            
                            Text(viewModel.dayNumber(day))
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Achievements Preview
    
    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: { showAchievements = true }) {
                    Text("View All")
                        .font(.bodySmall)
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentAchievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    // MARK: - Premium CTA
    
    private var premiumCTA: some View {
        Button(action: { showPremium = true }) {
            GlassCard {
                HStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient.goldGradient)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upgrade to Premium")
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        Text("Unlimited words & AI explanations")
                            .font(.bodySmall)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(20)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: LinearGradient
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(gradient)
                
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? LinearGradient.goldGradient : LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            Text(achievement.title)
                .font(.caption)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
            
            if achievement.isUnlocked {
                XPBadge(xp: achievement.xpReward, size: .small)
            } else {
                ProgressBar(
                    progress: achievement.progress,
                    height: 4,
                    foregroundGradient: .brandGradient
                )
                .frame(width: 60)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    ProfileView(
        dataManager: DataManager(),
        profile: UserProfile(name: "Alex")
    )
}
