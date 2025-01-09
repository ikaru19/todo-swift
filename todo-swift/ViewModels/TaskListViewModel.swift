//
//  TaskViewModel.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class TaskListViewModel {
    var tasks: BehaviorRelay<[(date: Date, tasks: [Task])]>
    
    private var realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
        self.tasks = BehaviorRelay(value: [])
        loadTasks()
    }
    
    private func loadTasks() {
        // Fetch all tasks from Realm and sort by full date (including time)
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        let allTasks = realm.objects(Task.self)
            .filter("date >= %@", startOfToday) // Filter tasks for today and beyond
            .sorted(byKeyPath: "date", ascending: true)
        
        print("Fetched all tasks (sorted by full date): \(allTasks.map { $0.date })")
        
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        // Group tasks by the date only (ignoring time)
        let groupedTasks = Dictionary(grouping: allTasks) { (task: Task) -> Date in
            // Extract the date component (ignoring time)
            let components = utcCalendar.dateComponents([.year, .month, .day], from: task.date)
            return utcCalendar.date(from: components)!
        }
        
        // Sort the grouped tasks by date (ignoring time)
        let sortedGroupedTasks = groupedTasks.sorted { $0.key < $1.key }
        var sortedTasksArray: [(date: Date, tasks: [Task])] = []
        
        // Sort tasks within each group by the full date (keeping time info intact for the tasks)
        for (date, tasksForDate) in sortedGroupedTasks {
            let sortedTasksForDate = tasksForDate.sorted { $0.date < $1.date }
            sortedTasksArray.append((date: date, tasks: sortedTasksForDate))
        }
        
        // Update tasks with the sorted and grouped data
        tasks.accept(sortedTasksArray)
    }


    // Method to format date into a string (dd-MM-yyyy format for grouping)
    static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
    
    // Method to convert formatted date string back into Date for sorting
    static func formatDateToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: dateString) ?? Date() // Default to current date if parsing fails
    }

    
    // Toggle task completion
    func toggleTaskCompletion(for task: Task) {
        do {
            try realm.write {
                task.isComplete.toggle()
            }
            loadTasks() // Reload tasks after the update
        } catch {
            print("Error toggling task completion: \(error)")
        }
    }
    
    // Delete a task
    func deleteTask(task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
            loadTasks() // Reload tasks after the deletion
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    
    // Update an existing task
    func updateTask(_ task: Task) {
        do {
            try realm.write {
                realm.add(task, update: .modified) // Use update mode to modify existing tasks
            }
            loadTasks() // Reload tasks after the update
        } catch {
            print("Error updating task: \(error)")
        }
    }
    
    // Add a new task
    func addTask(_ taskDataModel: TaskDataModel) {
        let task = Task()
        task.title = taskDataModel.title
        task.descriptionText = taskDataModel.descriptionText
        task.date = taskDataModel.date
        task.isComplete = taskDataModel.isComplete
        
        do {
            try realm.write {
                realm.add(task)
            }
            loadTasks() // Reload tasks after the addition
        } catch {
            print("Error adding task: \(error)")
        }
    }
    
    // Move task to a new date (section)
    func moveTask(task: Task, to newDate: Date) {
        do {
            try realm.write {
                task.date = newDate // Update the task's date
            }
            loadTasks() 
        } catch {
            print("Error moving task: \(error)")
        }
    }
}
