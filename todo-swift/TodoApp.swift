//
//  TodoApp.swift
//  todo-swift
//
//  Created by Syafrizal on 13/03/25.
//

import SwiftUI
import RealmSwift

@main
struct TodoApp: App {
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}
