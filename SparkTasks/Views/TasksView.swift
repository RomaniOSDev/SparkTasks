//
//  TasksView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct TasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var activityManager: ActivityManager
    @State private var showingAddTask = false
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tasks")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(taskManager.completedTasksCount) of \(taskManager.tasks.count) completed")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingAddTask = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("Search tasks...", text: $searchText)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.title,
                                isSelected: selectedFilter == filter,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedFilter = filter
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTasks) { task in
                        TaskRow(
                            task: task,
                            onToggle: {
                                taskManager.toggleTask(task)
                            },
                            onDelete: {
                                taskManager.deleteTask(task)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskManager: taskManager, activityManager: activityManager)
        }
    }
    
    private var filteredTasks: [Task] {
        let filtered = taskManager.tasks.filter { task in
            if searchText.isEmpty {
                return true
            } else {
                return task.title.localizedCaseInsensitiveContains(searchText) ||
                       task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .pending:
            return filtered.filter { !$0.isCompleted }
        case .completed:
            return filtered.filter { $0.isCompleted }
        case .highPriority:
            return filtered.filter { $0.priority == .high }
        }
    }
}

enum TaskFilter: CaseIterable {
    case all, pending, completed, highPriority
    
    var title: String {
        switch self {
        case .all: return "All"
        case .pending: return "Active"
        case .completed: return "Completed"
        case .highPriority: return "Important"
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                              LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [Color.clear, Color.clear], startPoint: .leading, endPoint: .trailing))
                )
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    @State private var showingEdit = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.green : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    if task.priority == .high {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                HStack {
                    Text(task.formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(task.priority.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(task.priority.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(task.priority.color.opacity(0.2))
                        )
                }
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    showingEdit = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .sheet(isPresented: $showingEdit) {
            EditTaskView(task: task, taskManager: TaskManager())
        }
    }
}

struct AddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var activityManager: ActivityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter task title...", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter task description...", text: $description, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priorityOption in
                                PriorityButton(
                                    priority: priorityOption,
                                    isSelected: priority == priorityOption,
                                    action: {
                                        priority = priorityOption
                                    }
                                )
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .colorScheme(.dark)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    let task = Task(
                        title: title,
                        description: description,
                        priority: priority,
                        dueDate: dueDate
                    )
                    taskManager.addTask(task)
                    activityManager.add(Activity(type: .taskCreated, title: "New Task", subtitle: title))
                    dismiss()
                }) {
                    Text("Add Task")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("New Task")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
    }
}

struct EditTaskView: View {
    let task: Task
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var dueDate: Date
    
    init(task: Task, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description)
        self._priority = State(initialValue: task.priority)
        self._dueDate = State(initialValue: task.dueDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter task title...", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter task description...", text: $description, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskPriority.allCases, id: \.self) { priorityOption in
                                PriorityButton(
                                    priority: priorityOption,
                                    isSelected: priority == priorityOption,
                                    action: {
                                        priority = priorityOption
                                    }
                                )
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .colorScheme(.dark)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    taskManager.updateTask(
                        task,
                        title: title,
                        description: description,
                        priority: priority,
                        dueDate: dueDate
                    )
                    dismiss()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Edit Task")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: priority.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : priority.color)
                
                Text(priority.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : priority.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? priority.color : priority.color.opacity(0.2))
            )
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
    }
}

#Preview {
    TasksView(taskManager: TaskManager(), activityManager: ActivityManager())
} 
