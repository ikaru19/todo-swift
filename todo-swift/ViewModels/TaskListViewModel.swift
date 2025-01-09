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
    var tasks: BehaviorRelay<[(date: Date, tasks: [TaskDataModel])]>
    
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
        var sortedTasksArray: [(date: Date, tasks: [TaskDataModel])] = []
        
        // Sort tasks within each group by the full date (keeping time info intact for the tasks)
        for (date, tasksForDate) in sortedGroupedTasks {
            // Convert each task to TaskDataModel
            let convertedTasksForDate = tasksForDate.map { convertTaskModel(data: $0) }
            
            // Sort converted tasks by the date (keeping time intact)
            let sortedConvertedTasksForDate = convertedTasksForDate.sorted { $0.date < $1.date }
            
            // Append the sorted and converted tasks
            sortedTasksArray.append((date: date, tasks: sortedConvertedTasksForDate))
        }
        
        tasks.accept(sortedTasksArray)
    }
    
    func convertTaskModel(data: Task) -> TaskDataModel {
        return TaskDataModel(
            id: data.id,
            title: data.title,
            descriptionText: data.descriptionText,
            date: data.date,
            isComplete: data.isComplete
        )
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
    func toggleTaskCompletion(for task: TaskDataModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            if let taskToToggle = realm.objects(Task.self).filter("id == %@", task.id).first {
                try realm.write {
                    taskToToggle.isComplete.toggle()
                }
                loadTasks()
                completion(.success(()))
            } else {
                print("Error: Task with the given ID not found.")
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found."])))
            }
        } catch {
            print("Error toggling task completion: \(error)")
            completion(.failure(error))
        }
    }

    
    // Delete a task
    func deleteTask(task: TaskDataModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            if let taskToDelete = realm.objects(Task.self).filter("id == %@", task.id).first {
                try realm.write {
                    realm.delete(taskToDelete)
                }
                loadTasks()
                completion(.success(()))
            } else {
                let error = NSError(domain: "TaskNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task with the given ID was not found."])
                completion(.failure(error))
            }
        } catch {
            print("Error deleting task: \(error)")
            completion(.failure(error))
        }
    }
    
    func addTask(_ taskDataModel: TaskDataModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let task = Task()
        task.title = taskDataModel.title
        task.descriptionText = taskDataModel.descriptionText
        task.date = taskDataModel.date
        task.isComplete = taskDataModel.isComplete
        
        do {
            try realm.write {
                realm.add(task)
            }
            loadTasks()
            
            completion(.success(()))
        } catch {
            print("Error adding task: \(error)")
            
            completion(.failure(error))
        }
    }
    
    func addTasks(_ taskDataModels: [TaskDataModel], completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try realm.write {
                for taskDataModel in taskDataModels {
                    let task = Task()
                    task.title = taskDataModel.title
                    task.descriptionText = taskDataModel.descriptionText
                    task.date = taskDataModel.date
                    task.isComplete = taskDataModel.isComplete
                    
                    realm.add(task)
                }
                
                loadTasks()
                completion(.success(()))
            }
        } catch {
            print("Error adding tasks: \(error)")
            completion(.failure(error))
        }
    }
    
    // Move task to a new date (section)
    func moveTask(task: TaskDataModel, to newDate: Date) {
        do {
            if let taskToMove = realm.objects(Task.self).filter("id == %@", task.id).first {
                try realm.write {
                    taskToMove.date = newDate
                }
                loadTasks()
            } else {
                print("Error: Task with the given ID not found.")
            }
        } catch {
            print("Error moving task: \(error)")
        }
    }
}
