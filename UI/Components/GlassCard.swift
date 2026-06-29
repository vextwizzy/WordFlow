//
//  GlassCard.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.1
    
    init(cornerRadius: CGFloat = 20, opacity: Double = 0.1, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient.brandGradient
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                // Animated blobs
                Circle()
                    .fill(Color.brandAccent.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: -100)
                
                Circle()
                    .fill(Color.brandSecondary.opacity(0.3))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
            }
        }
    }
}

#Preview {
    ZStack {
        GlassBackground()
        
        GlassCard {
            VStack(spacing: 16) {
                Text("Glass Card")
                    .font(.title1)
                    .foregroundStyle(.white)
                
                Text("Beautiful glassmorphism effect")
                    .font(.bodyRegular)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(24)
        }
        .padding()
    }
}
