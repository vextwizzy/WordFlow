//
//  LevelBadge.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct LevelBadge: View {
    let level: Int
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient.goldGradient,
                    lineWidth: 3
                )
                .frame(width: size, height: size)
            
            // Inner background
            Circle()
                .fill(LinearGradient.goldGradient)
                .frame(width: size - 6, height: size - 6)
            
            // Level number
            Text("\(level)")
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .shadow(color: .xpGold.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct LevelProgressBar: View {
    let currentXP: Int
    let requiredXP: Int
    
    var progress: Double {
        guard requiredXP > 0 else { return 0 }
        return min(Double(currentXP) / Double(requiredXP), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level Progress")
                    .font(.bodySmall)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Text("\(currentXP) / \(requiredXP) XP")
                    .font(.bodySmall)
                    .foregroundStyle(Color.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    Capsule()
                        .fill(LinearGradient.goldGradient)
                        .frame(width: geometry.size.width * progress)
                        .animation(.smooth, value: progress)
                }
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LevelBadge(level: 5)
        LevelBadge(level: 12, size: 80)
        
        LevelProgressBar(currentXP: 350, requiredXP: 500)
            .padding()
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
