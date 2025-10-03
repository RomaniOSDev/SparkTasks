//
//  NotesView.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 03.10.2025.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var notesManager: NotesManager
    @ObservedObject var activityManager: ActivityManager
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedCategory: NoteCategory = .all
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(notesManager.notes.count) notes")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingAddNote = true
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
                                            colors: [.green, .mint],
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
                    
                    TextField("Search notes...", text: $searchText)
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
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedCategory = category
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
            
            if filteredNotes.isEmpty {
                EmptyNotesView()
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(filteredNotes) { note in
                            NoteCard(
                                note: note,
                                onDelete: {
                                    notesManager.deleteNote(note)
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
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(notesManager: notesManager, activityManager: activityManager)
        }
    }
    
    private var filteredNotes: [Note] {
        let filtered = notesManager.notes.filter { note in
            if searchText.isEmpty {
                return selectedCategory == .all || note.category == selectedCategory
            } else {
                return (selectedCategory == .all || note.category == selectedCategory) &&
                       (note.title.localizedCaseInsensitiveContains(searchText) ||
                        note.content.localizedCaseInsensitiveContains(searchText))
            }
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
}

struct EmptyNotesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "note.text")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 10) {
                Text("No Notes")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create your first note")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct CategoryFilterButton: View {
    let category: NoteCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(category.title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? 
                          LinearGradient(colors: [category.color, category.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color.clear, Color.clear], startPoint: .leading, endPoint: .trailing))
            )
        }
    }
}

struct NoteCard: View {
    let note: Note
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: note.category.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(note.category.color)
                    
                    Spacer()
                    
                    Menu {
                        Button("Edit") {
                            showingDetail = true
                        }
                        
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Text(note.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                HStack {
                    Text(note.formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(note.category.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(note.category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(note.category.color.opacity(0.2))
                        )
                }
            }
            .padding(15)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            NoteDetailView(note: note, notesManager: NotesManager())
        }
    }
}

struct AddNoteView: View {
    @ObservedObject var notesManager: NotesManager
    @ObservedObject var activityManager: ActivityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: NoteCategory = .personal
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter title...", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter note content...", text: $content, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(5...10)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(NoteCategory.allCases.filter { $0 != .all }, id: \.self) { categoryOption in
                                CategorySelectionButton(
                                    category: categoryOption,
                                    isSelected: category == categoryOption,
                                    action: {
                                        category = categoryOption
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    let note = Note(
                        title: title,
                        content: content,
                        category: category
                    )
                    notesManager.addNote(note)
                    activityManager.add(Activity(type: .noteCreated, title: "Note created", subtitle: title))
                    dismiss()
                }) {
                    Text("Create Note")
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
                    Text("New Note")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
    }
}

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var notesManager: NotesManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var category: NoteCategory
    
    init(note: Note, notesManager: NotesManager) {
        self.note = note
        self.notesManager = notesManager
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
        self._category = State(initialValue: note.category)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter title...", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        TextField("Enter note content...", text: $content, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(5...10)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(NoteCategory.allCases.filter { $0 != .all }, id: \.self) { categoryOption in
                                CategorySelectionButton(
                                    category: categoryOption,
                                    isSelected: category == categoryOption,
                                    action: {
                                        category = categoryOption
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    notesManager.updateNote(
                        note,
                        title: title,
                        content: content,
                        category: category
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
                    Text("Edit Note")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
    }
}

struct CategorySelectionButton: View {
    let category: NoteCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : category.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : category.color.opacity(0.2))
            )
        }
    }
}

#Preview {
    NotesView(notesManager: NotesManager(), activityManager: ActivityManager())
} 
