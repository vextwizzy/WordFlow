//
//  TabBarView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    let dataManager: DataManager
    let profile: UserProfile
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home - Word Cards
            WordCardStackView(dataManager: dataManager, profile: profile)
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(0)
            
            // Statistics
            StatisticsView(dataManager: dataManager, profile: profile)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // Profile
            ProfileView(dataManager: dataManager, profile: profile)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(.brandPrimary)
    }
}

#Preview {
    TabBarView(
        dataManager: DataManager(),
        profile: UserProfile(name: "Alex")
    )
}
