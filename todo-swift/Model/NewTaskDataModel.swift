//
//  TaskDataModel.swift
//  todo-swift
//
//  Created by Syafrizal on 13/03/25.
//


import Foundation
import RealmSwift

class NewTaskDataModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var taskDescription: String = ""
    @Persisted var dueDate: Date = Date()
    @Persisted var isCompleted: Bool = false
    @Persisted var createdAt: Date = Date()
    
    convenience init(title: String, description: String, dueDate: Date) {
        self.init()
        self.title = title
        self.taskDescription = description
        self.dueDate = dueDate
    }
}
