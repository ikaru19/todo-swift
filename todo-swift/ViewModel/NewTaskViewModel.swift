//
//  NewTaskViewModel.swift
//  todo-swift
//
//  Created by Syafrizal on 13/03/25.
//

import Foundation
import RealmSwift
import Combine

class NewTaskViewModel: ObservableObject {
    private var realm: Realm
    @Published var tasksByDate: [(date: Date, tasks: [NewTaskDataModel])] = []
    
    init() {
        self.realm = try! Realm()
        loadTasks()
    }
    
    func loadTasks() {
        let tasks = realm.objects(NewTaskDataModel.self)
            .sorted(byKeyPath: "dueDate", ascending: true)
        
        let groupedTasks = Dictionary(grouping: tasks) { task in
            Calendar.current.startOfDay(for: task.dueDate)
        }
        
        tasksByDate = groupedTasks.map { (date: $0.key, tasks: Array($0.value)) }
            .sorted { $0.date < $1.date }
    }
    
    func addTask(title: String, description: String, dueDate: Date) {
        let task = NewTaskDataModel(title: title, description: description, dueDate: dueDate)
        try? realm.write {
            realm.add(task)
        }
        loadTasks()
    }
    
    func toggleTaskCompletion(task: NewTaskDataModel) {
        try? realm.write {
            task.isCompleted.toggle()
        }
        loadTasks()
    }
    
    func deleteTask(task: NewTaskDataModel) {
        try? realm.write {
            realm.delete(task)
        }
        loadTasks()
    }
    
    // For testing purposes - similar to the UIKit version
    func insertMockData() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        
        let tasks = [
            NewTaskDataModel(title: "Complete SwiftUI conversion", description: "Convert the UIKit app to SwiftUI", dueDate: today),
            NewTaskDataModel(title: "Test the app", description: "Make sure everything works correctly", dueDate: tomorrow),
            NewTaskDataModel(title: "Submit to App Store", description: "Prepare and submit the app", dueDate: dayAfterTomorrow)
        ]
        
        try? realm.write {
            for task in tasks {
                realm.add(task)
            }
        }
        
        loadTasks()
    }
    
    func isFirstLaunch() -> Bool {
        let key = "hasLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
        return false
    }
}

// MARK: - Drag and Drop
extension NewTaskViewModel {
    func moveTask(from sourceIndex: Int, to destinationIndex: Int, inSection sectionDate: Date) {
        // Find the section in tasksByDate
        guard let sectionIndex = tasksByDate.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: sectionDate) }) else {
            return
        }
        
        // Get the tasks for this section
        var tasks = tasksByDate[sectionIndex].tasks
        
        // Make sure indices are valid
        guard sourceIndex < tasks.count && destinationIndex < tasks.count else {
            return
        }
        
        // Get the task to move
        let task = tasks[sourceIndex]
        
        // Update the order in Realm
        try? realm.write {
            // Remove from source position
            tasks.remove(at: sourceIndex)
            
            // Insert at destination position
            if destinationIndex >= tasks.count {
                tasks.append(task)
            } else {
                tasks.insert(task, at: destinationIndex)
            }
            
            // Update the tasksByDate array
            tasksByDate[sectionIndex].tasks = tasks
        }
        
        // Reload tasks to refresh the UI
        loadTasks()
    }
    
    func moveTaskBetweenSections(task: NewTaskDataModel, fromSection: Date, toSection: Date, toIndex: Int) {
        // Update the task's due date to the new section date
        try? realm.write {
            // Set the task's due date to the new section date, preserving the time
            let calendar = Calendar.current
            let taskTime = calendar.dateComponents([.hour, .minute, .second], from: task.dueDate)
            let newSectionDay = calendar.dateComponents([.year, .month, .day], from: toSection)
            
            var newDateComponents = DateComponents()
            newDateComponents.year = newSectionDay.year
            newDateComponents.month = newSectionDay.month
            newDateComponents.day = newSectionDay.day
            newDateComponents.hour = taskTime.hour
            newDateComponents.minute = taskTime.minute
            newDateComponents.second = taskTime.second
            
            if let newDate = calendar.date(from: newDateComponents) {
                task.dueDate = newDate
            }
        }
        
        // Reload tasks to refresh the UI
        loadTasks()
    }
}

