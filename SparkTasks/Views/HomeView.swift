//
//  HomeView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI
import Combine

struct HomeView: View {
    @AppStorage("userName") private var userName: String = "User"
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var notesManager: NotesManager
    @ObservedObject var activityManager: ActivityManager
    @State private var currentTime = Date()
    @State private var isAnimating = false
    @State private var showingAddTask = false
    @State private var showingAddNote = false
    @Binding var selectedTab: Int
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(greeting)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(userName)
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
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
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text(String(userName.prefix(1)).uppercased())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(timeString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ProgressCard(
                    completedTasks: taskManager.completedTasksCount,
                    totalTasks: taskManager.tasks.count
                )
                
                QuickActionsView(
                    onAddTask: { showingAddTask = true },
                    onAddNote: { showingAddNote = true },
                    onMotivation: { selectedTab = 2 }
                )
                
                StatsGridView(
                    completedTasks: taskManager.completedTasksCount,
                    notesCount: notesManager.notes.count
                )
                
                RecentActivityView(activities: activityManager.activities)
            }
            .padding(.bottom, 100)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskManager: taskManager, activityManager: activityManager)
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(notesManager: notesManager, activityManager: activityManager)
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }
}

struct ProgressCard: View {
    let completedTasks: Int
    let totalTasks: Int
    
    private var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Progress")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(completedTasks) of \(totalTasks) tasks completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 1), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

struct QuickActionsView: View {
    let onAddTask: () -> Void
    let onAddNote: () -> Void
    let onMotivation: () -> Void
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 15) {
                QuickActionButton(
                    title: "New Task",
                    icon: "plus.circle.fill",
                    color: [.blue, .cyan],
                    action: onAddTask
                )
                
                QuickActionButton(
                    title: "Note",
                    icon: "note.text",
                    color: [.green, .mint],
                    action: onAddNote
                )
                
                QuickActionButton(
                    title: "Motivation",
                    icon: "sparkles",
                    color: [.orange, .red],
                    action: onMotivation
                )
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isPressed = false }
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: color,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

struct StatsGridView: View {
    let completedTasks: Int
    let notesCount: Int
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Stats")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Tasks Completed",
                    value: "\(completedTasks)",
                    icon: "checkmark.circle.fill",
                    color: [.green, .mint]
                )
                
                StatCard(
                    title: "Notes Created",
                    value: "\(notesCount)",
                    icon: "note.text",
                    color: [.blue, .cyan]
                )
                
                StatCard(
                    title: "Days in a row",
                    value: "—",
                    icon: "flame.fill",
                    color: [.orange, .red]
                )
                
                StatCard(
                    title: "Productivity",
                    value: "—",
                    icon: "chart.line.uptrend.xyaxis",
                    color: [.purple, .pink]
                )
            }
            .padding(.horizontal, 20)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: color,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct RecentActivityView: View {
    let activities: [Activity]
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            if activities.isEmpty {
                Text("No recent events")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(activities.prefix(10)) { activity in
                        ActivityRow(
                            title: activity.type == .taskCompleted ? "Task Completed" : activity.type == .noteCreated ? "Note Created" : "New Task",
                            subtitle: activity.subtitle,
                            time: timeAgoString(from: activity.date),
                            icon: activity.type.icon,
                            color: activity.type.color
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    private func timeAgoString(from date: Date) -> String {
        let interval = Int(Date().timeIntervalSince(date))
        let minutes = interval / 60
        let hours = minutes / 60
        if hours > 0 {
            return "\(hours) hour" + (hours == 1 ? "" : "s") + " ago"
        } else if minutes > 0 {
            return "\(minutes) min ago"
        } else {
            return "Just now"
        }
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
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
            
            Text(time)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Activity Model
struct Activity: Identifiable, Codable {
    let id: UUID
    let type: ActivityType
    let title: String
    let subtitle: String
    let date: Date
    
    init(type: ActivityType, title: String, subtitle: String, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.date = date
    }
}

enum ActivityType: String, Codable {
    case taskCompleted, noteCreated, taskCreated
    
    var icon: String {
        switch self {
        case .taskCompleted: return "checkmark.circle.fill"
        case .noteCreated: return "note.text"
        case .taskCreated: return "plus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .taskCompleted: return .green
        case .noteCreated: return .blue
        case .taskCreated: return .orange
        }
    }
}

class ActivityManager: ObservableObject {
    @Published var activities: [Activity] = []
    private let key = "recent_activities"
    private let maxCount = 20
    
    init() {
        load()
    }
    
    func add(_ activity: Activity) {
        activities.insert(activity, at: 0)
        if activities.count > maxCount {
            activities = Array(activities.prefix(maxCount))
        }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        }
    }
    
    func resetData() {
        activities.removeAll()
        save()
    }
} 
