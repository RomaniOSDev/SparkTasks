//
//  SettingsView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true
    @State private var showingResetAlert = false
    @State private var showingNameEdit = false
    @State private var tempUserName = ""
    
    let taskManager: TaskManager
    let notesManager: NotesManager
    let activityManager: ActivityManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Personalization and data management")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                ProfileSection(
                    userName: userName,
                    onEditName: {
                        tempUserName = userName
                        showingNameEdit = true
                    }
                )
                
                DataManagementSection(
                    onResetData: {
                        showingResetAlert = true
                    }
                )
                
                AboutSection()
                
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .alert("Change Name", isPresented: $showingNameEdit) {
            TextField("Enter name", text: $tempUserName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                userName = tempUserName
            }
        } message: {
            Text("Enter your name to personalize the app")
        }
        .alert("Reset Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This action will delete all tasks, notes and settings. This action cannot be undone.")
        }
    }
    
    private func resetAllData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        UserDefaults.standard.set("User", forKey: "userName")
        UserDefaults.standard.set(0, forKey: "completedTasksCount")
        UserDefaults.standard.set(0, forKey: "totalTasksCount")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        userName = "User"
        
        taskManager.resetData()
        notesManager.resetData()
        activityManager.resetData()
    }
}

struct ProfileSection: View {
    let userName: String
    let onEditName: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Text(String(userName.prefix(1)).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("SparkTasks User")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: onEditName) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
}

struct DataManagementSection: View {
    let onResetData: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Data Management")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRowButton(
                    icon: "trash.fill",
                    title: "Reset Data",
                    subtitle: "Delete all tasks and notes",
                    color: .red,
                    action: onResetData
                )
            }
        }
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("About")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRowButton(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Leave a review in App Store",
                    color: .yellow,
                    action: {
                        requestAppStoreReview()
                    }
                )
                
                SettingsRowButton(
                    icon: "doc.text.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    color: .blue,
                    action: {
                        openPrivacyPolicy()
                    }
                )
            }
        }
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

func requestAppStoreReview() {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
    }
}

func openPrivacyPolicy() {
    if let url = URL(string: "https://www.termsfeed.com/live/b899c213-eea7-4d2a-b932-9e4112d90339") {
        UIApplication.shared.open(url)
    }
}


#Preview {
    SettingsView(taskManager: TaskManager(), notesManager: NotesManager(), activityManager: ActivityManager())
} 
