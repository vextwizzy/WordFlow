//
//  ProgressBar.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var foregroundGradient: LinearGradient = .brandGradient
    var showPercentage: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(backgroundColor)
                    
                    // Progress
                    Capsule()
                        .fill(foregroundGradient)
                        .frame(width: geometry.size.width * min(progress, 1.0))
                        .animation(.smooth, value: progress)
                }
            }
            .frame(height: height)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    var size: CGFloat = 100
    var lineWidth: CGFloat = 10
    var gradient: LinearGradient = .brandGradient
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.smooth, value: progress)
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressBar(progress: 0.7, showPercentage: true)
            .frame(width: 300)
        
        ProgressBar(progress: 0.3, height: 12, foregroundGradient: .successGradient)
            .frame(width: 300)
        
        CircularProgressBar(progress: 0.65)
        
        CircularProgressBar(progress: 0.85, size: 120, gradient: .goldGradient)
    }
    .padding()
}
