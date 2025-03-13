//
//  TaskListView.swift
//  todo-swift
//
//  Created by Syafrizal on 13/03/25.
//

import SwiftUI
import RealmSwift

struct TaskListView: View {
    @StateObject private var viewModel = NewTaskViewModel()
    @State private var showingAddTask = false
    @State private var draggedTask: NewTaskDataModel?
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.tasksByDate.isEmpty {
                    Text("No tasks yet. Add a new task to get started!")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.tasksByDate, id: \.date) { section in
                        Section(header: NewTaskHeaderView(date: section.date)) {
                            ForEach(section.tasks) { task in
                                TaskRowView(task: task, viewModel: viewModel)
                                    .onDrag {
                                        // Set the currently dragged task
                                        self.draggedTask = task
                                        // Return NSItemProvider with task ID
                                        return NSItemProvider(object: task.id as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: TaskDropDelegate(
                                        item: task,
                                        listData: viewModel.tasksByDate,
                                        current: $draggedTask,
                                        sectionDate: section.date,
                                        viewModel: viewModel)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Task List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .onAppear {
                if viewModel.isFirstLaunch() {
                    viewModel.insertMockData()
                }
            }
        }
    }
}

struct NewTaskHeaderView: View {
    let date: Date
    
    var body: some View {
        Text(formattedDate(date))
            .font(.headline)
            .foregroundColor(.primary)
            .textCase(nil)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if Calendar.current.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

struct TaskRowView: View {
    let task: NewTaskDataModel
    let viewModel: NewTaskViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                if !task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(task.taskDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.toggleTaskCompletion(task: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteTask(task: task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// Drop delegate to handle the drop operation
struct TaskDropDelegate: DropDelegate {
    let item: NewTaskDataModel
    let listData: [(date: Date, tasks: [NewTaskDataModel])]
    @Binding var current: NewTaskDataModel?
    let sectionDate: Date
    let viewModel: NewTaskViewModel
    
    func dropEntered(info: DropInfo) {
        // Highlight the drop area if needed
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let current = current else {
            return false
        }
        
        // Find the source section
        var sourceSection: Date?
        var sourceIndex: Int?
        
        for (sectionIndex, section) in listData.enumerated() {
            if let index = section.tasks.firstIndex(where: { $0.id == current.id }) {
                sourceSection = section.date
                sourceIndex = index
                break
            }
        }
        
        // Find the destination section and index
        let destinationSection = sectionDate
        let destinationIndex = listData.first(where: { $0.date == destinationSection })?
            .tasks.firstIndex(where: { $0.id == item.id }) ?? 0
        
        // If we found both source and destination, perform the move
        if let sourceSection = sourceSection, let sourceIndex = sourceIndex {
            // Move within the same section
            if Calendar.current.isDate(sourceSection, inSameDayAs: destinationSection) {
                viewModel.moveTask(
                    from: sourceIndex,
                    to: destinationIndex,
                    inSection: sourceSection
                )
            } else {
                // Move between different sections (change due date)
                viewModel.moveTaskBetweenSections(
                    task: current,
                    fromSection: sourceSection,
                    toSection: destinationSection,
                    toIndex: destinationIndex
                )
            }
            return true
        }
        
        return false
    }
}