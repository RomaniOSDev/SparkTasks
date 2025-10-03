//
//  OnboardingView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    
    private let onboardingData = [
        OnboardingPage(
            title: "Welcome to SparkTasks!",
            subtitle: "Your personal assistant for achieving goals",
            image: "sparkles",
            color: [Color.purple, Color.pink]
        ),
        OnboardingPage(
            title: "Manage Tasks",
            subtitle: "Create, edit and track progress of your tasks",
            image: "checklist",
            color: [Color.blue, Color.cyan]
        ),
        OnboardingPage(
            title: "Daily Motivation",
            subtitle: "Get inspired with motivational quotes",
            image: "heart.fill",
            color: [Color.orange, Color.red]
        ),
        OnboardingPage(
            title: "Write Ideas",
            subtitle: "Create notes and save important thoughts",
            image: "note.text",
            color: [Color.green, Color.mint]
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingData[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                HStack(spacing: 8) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? .white : .white.opacity(0.3))
                            .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    
                    Button(currentPage == onboardingData.count - 1 ? "Start" : "Next") {
                        if currentPage == onboardingData.count - 1 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                hasCompletedOnboarding = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: onboardingData[currentPage].color,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let color: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.color,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: page.image)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.2, blue: 0.5)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 50...150))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .blur(radius: 20)
                    .scaleEffect(animateGradient ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animateGradient
                    )
            }
        }
        .onAppear {
            animateGradient = true
        }
    }
}

#Preview {
    OnboardingView()
} 
