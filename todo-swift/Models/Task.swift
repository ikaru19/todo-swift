//
//  Task.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var time: Date = Date()
    @objc dynamic var isComplete: Bool = false
}
