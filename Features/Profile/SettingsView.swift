//
//  SettingsView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var profile: UserProfile
    @State private var notificationTime = Date()
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()
                    .ignoresSafeArea()
                
                Form {
                    // Profile Section
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(profile.name)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(profile.email.isEmpty ? "Not set" : profile.email)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Profile")
                    }
                    
                    // Study Goals Section
                    Section {
                        Stepper("Daily Goal: \(profile.dailyGoal) words", value: $profile.dailyGoal, in: 10...100, step: 10)
                    } header: {
                        Text("Study Goals")
                    } footer: {
                        Text("Set your daily learning goal")
                    }
                    
                    // Notifications Section
                    Section {
                        Toggle("Enable Notifications", isOn: $profile.notificationsEnabled)
                            .onChange(of: profile.notificationsEnabled) { _, newValue in
                                if newValue {
                                    Task {
                                        _ = await NotificationService.shared.requestAuthorization()
                                    }
                                }
                                NotificationService.shared.scheduleDaily(at: notificationTime, enabled: newValue)
                            }
                        
                        if profile.notificationsEnabled {
                            DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                .onChange(of: notificationTime) { _, newValue in
                                    profile.notificationTime = newValue
                                    NotificationService.shared.scheduleDaily(at: newValue, enabled: true)
                                }
                        }
                    } header: {
                        Text("Notifications")
                    }
                    
                    // Premium Section
                    Section {
                        HStack {
                            Label("Premium Status", systemImage: "crown.fill")
                            Spacer()
                            Text(profile.isPremium ? "Active" : "Free")
                                .foregroundStyle(profile.isPremium ? .success : .secondary)
                        }
                        
                        if !profile.isPremium {
                            Button(action: {}) {
                                Label("Upgrade to Premium", systemImage: "star.fill")
                                    .foregroundStyle(.brandPrimary)
                            }
                        }
                    } header: {
                        Text("Subscription")
                    }
                    
                    // Data & Privacy Section
                    Section {
                        Button(action: { showResetConfirmation = true }) {
                            Label("Reset Progress", systemImage: "arrow.counterclockwise")
                                .foregroundStyle(.error)
                        }
                        
                        Button(action: {}) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } header: {
                        Text("Data & Privacy")
                    }
                    
                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button(action: {}) {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                        }
                        
                        Button(action: {}) {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                        }
                        
                        Button(action: {}) {
                            Label("Contact Support", systemImage: "envelope.fill")
                        }
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .alert("Reset Progress", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("This will delete all your progress, including learned words, achievements, and statistics. This action cannot be undone.")
            }
        }
        .onAppear {
            if let savedTime = profile.notificationTime {
                notificationTime = savedTime
            }
        }
    }
    
    private func resetProgress() {
        profile.level = 1
        profile.xp = 0
        profile.currentStreak = 0
        profile.longestStreak = 0
        profile.totalWordsLearned = 0
        profile.totalStudyTime = 0
        profile.lastStudyDate = nil
        
        // Reset achievements
        for achievement in profile.achievements {
            achievement.isUnlocked = false
            achievement.currentProgress = 0
            achievement.unlockedAt = nil
        }
    }
}

#Preview {
    SettingsView(profile: UserProfile(name: "Alex"))
}
