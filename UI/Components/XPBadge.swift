//
//  XPBadge.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct XPBadge: View {
    let xp: Int
    var size: XPBadgeSize = .medium
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: size.iconSize))
            
            Text("+\(xp)")
                .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(LinearGradient.goldGradient)
        )
        .shadow(color: .xpGold.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

enum XPBadgeSize {
    case small, medium, large
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 16
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 18
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        XPBadge(xp: 10, size: .small)
        XPBadge(xp: 50, size: .medium)
        XPBadge(xp: 100, size: .large)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
