//
//  Task.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var descriptionText: String = ""
    @Persisted var date: Date = Date()
    @Persisted var isComplete: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"  // Mark id as the primary key
    }
}
