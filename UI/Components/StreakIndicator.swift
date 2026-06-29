//
//  StreakIndicator.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct StreakIndicator: View {
    let streak: Int
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: isCompact ? 16 : 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            if !isCompact {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(streak == 1 ? "day" : "days")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else {
                Text("\(streak)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, isCompact ? 12 : 16)
        .padding(.vertical, isCompact ? 6 : 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakIndicator(streak: 7)
        StreakIndicator(streak: 30, isCompact: true)
    }
    .padding()
    .background(LinearGradient.brandGradient)
}
