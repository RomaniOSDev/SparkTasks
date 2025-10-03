//
//  ContentView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject var taskManager = TaskManager()
    @StateObject var notesManager = NotesManager()
    @StateObject var activityManager = ActivityManager()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    HomeView(taskManager: taskManager, notesManager: notesManager, activityManager: activityManager, selectedTab: $selectedTab)
                        .tag(0)
                    
                    TasksView(taskManager: taskManager, activityManager: activityManager)
                        .tag(1)
                    
                    MotivationView()
                        .tag(2)
                    
                    NotesView(notesManager: notesManager, activityManager: activityManager)
                        .tag(3)
                    
                    SettingsView(taskManager: taskManager, notesManager: notesManager, activityManager: activityManager)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.light)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("house.fill", "Home"),
        ("checklist", "Tasks"),
        ("sparkles", "Motivation"),
        ("note.text", "Notes"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                        
                        Text(tabs[index].1)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == index ? 
                                  LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [Color.clear, Color.clear], startPoint: .leading, endPoint: .trailing))
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    MainTabView()
}
