//
//  AddTaskView.swift
//  todo-swift
//
//  Created by Syafrizal on 13/03/25.
//


import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: NewTaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker("Select Date", selection: $dueDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    viewModel.addTask(
                        title: title,
                        description: description,
                        dueDate: dueDate
                    )
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}
