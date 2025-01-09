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
    private var realm: Realm
    private let disposeBag = DisposeBag()
    
    
    private let tasksSubject = BehaviorSubject<[String: [Task]]>(value: [:])
    var tasks: Observable<[String: [Task]]> {
        return tasksSubject.asObservable()
    }
    
    
    init() {
        self.realm = try! Realm()
        // Initially load tasks and group them by date
        let initialTasks = self.realm.objects(Task.self)
        let groupedTasks = self.groupTasksByDate(tasks: initialTasks)
        tasksSubject.onNext(groupedTasks)
    }
    
    // Add a new task
    func addTask(title: String, description: String, date: Date, time: Date) {
        let task = Task()
        task.title = title
        task.descriptionText = description
        task.date = date
        task.time = time
        
        try! realm.write {
            realm.add(task)
        }
        
        // After adding a new task, update the grouped tasks
        let updatedTasks = self.realm.objects(Task.self)
        let groupedTasks = self.groupTasksByDate(tasks: updatedTasks)
        tasksSubject.onNext(groupedTasks)
    }
    
    // Delete a task
    func deleteTask(task: Task) {
        try! realm.write {
            realm.delete(task)
        }
        
        // After deleting a task, update the grouped tasks
        let updatedTasks = self.realm.objects(Task.self)
        let groupedTasks = self.groupTasksByDate(tasks: updatedTasks)
        tasksSubject.onNext(groupedTasks)
    }
    
    // Toggle task completion
    func toggleTaskCompletion(for task: Task) {
        try! realm.write {
            task.isComplete.toggle()  // Toggle the completion status of the task
        }
        
        // After toggling the completion status, update the grouped tasks
        let updatedTasks = self.realm.objects(Task.self)
        let groupedTasks = self.groupTasksByDate(tasks: updatedTasks)
        tasksSubject.onNext(groupedTasks)
    }
    
    // Group tasks by date
    private func groupTasksByDate(tasks: Results<Task>) -> [String: [Task]] {
        var groupedTasks = [String: [Task]]()
        
        for task in tasks {
            let dateString = self.formatDate(task.date)
            if groupedTasks[dateString] != nil {
                groupedTasks[dateString]?.append(task)
            } else {
                groupedTasks[dateString] = [task]
            }
        }
        
        return groupedTasks
    }
    
    // Format date for grouping
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
