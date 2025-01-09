//
//  TaskDataModel.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation

struct TaskDataModel {
    var id: String?
    var title: String
    var descriptionText: String
    var date: Date
    var isComplete: Bool
}

extension TaskDataModel: Equatable {
    static func ==(lhs: TaskDataModel, rhs: TaskDataModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.descriptionText == rhs.descriptionText &&
        lhs.date == rhs.date &&
        lhs.isComplete == rhs.isComplete
    }
}
