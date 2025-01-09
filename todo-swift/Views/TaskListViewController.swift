//
//  TaskListViewController.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import UIKit
import SnapKit
import RealmSwift
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController {
    private var tableView: UITableView?
    private var addButton: UIButton?
    private var disposeBag = DisposeBag()
    private var viewModel: TaskListViewModel
    
    private var tasks: [(date: Date, tasks: [TaskDataModel])] = []
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Test Function
        if isFirstLaunch() {
            insertMockData()
        }
        
        
        setupNavigation()
        setupUI()
        setupTable()
        bindViewModel()
    }
    
    private func setupNavigation() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"
        let addButton = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func bindViewModel() {
        viewModel.tasks
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newTasks in
                guard let self = self else { return }
                
                // Handle empty task scenario
                if self.tasks.isEmpty {
                    self.tasks = newTasks
                    self.tableView?.reloadData()
                    return
                }
                
                let oldTasks = self.tasks
                self.tasks = newTasks
                
                var deletedSections: IndexSet = []
                var insertedSections: IndexSet = []
                var reloadedSections: IndexSet = []
                
                // Check for deleted sections
                for (index, oldSection) in oldTasks.enumerated() {
                    if !newTasks.contains(where: { $0.date == oldSection.date }) {
                        deletedSections.insert(index)
                    }
                }
                
                // Check for inserted sections
                for (index, newSection) in newTasks.enumerated() {
                    if !oldTasks.contains(where: { $0.date == newSection.date }) {
                        insertedSections.insert(index)
                    }
                }
                
                // Check for reloaded sections
                for (index, newSection) in newTasks.enumerated() {
                    if let oldSectionIndex = oldTasks.firstIndex(where: { $0.date == newSection.date }) {
                        let oldSection = oldTasks[oldSectionIndex]
                        
                        // Compare the task arrays for changes
                        if oldSection.tasks != newSection.tasks {
                            if !deletedSections.contains(oldSectionIndex) {
                                reloadedSections.insert(oldSectionIndex)
                            }
                        }
                    }
                }
                
                // Perform updates on the table view
                self.tableView?.beginUpdates()
                
                if !deletedSections.isEmpty {
                    self.tableView?.deleteSections(deletedSections, with: .automatic)
                }
                
                if !insertedSections.isEmpty {
                    self.tableView?.insertSections(insertedSections, with: .automatic)
                }
                
                if !reloadedSections.isEmpty {
                    self.tableView?.reloadSections(reloadedSections, with: .automatic)
                }
                
                self.tableView?.endUpdates()
            })
            .disposed(by: disposeBag)

    }
    
    private func showError(error: Error){
        let alertController = UIAlertController(
            title: "Error",
            message: "Failed to add task: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        // Add an OK action to dismiss the alert
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapAddButton() {
        let vc = AddTaskViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UI SETUP
private extension TaskListViewController {
    private func setupUI() {
        let tableView = initTableView()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.tableView = tableView
    }
    
    private func setupTable() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.sectionHeaderTopPadding = 0
        tableView?.dragInteractionEnabled = true
        tableView?.dragDelegate = self
        tableView?.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
    }
    
    private func initTableView() -> UITableView {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
}

// MARK: CELL DELEGATE
extension TaskListViewController: TaskCellDelegate {
    func onCompleteUpdated(for task: TaskDataModel) {
        viewModel.toggleTaskCompletion(for: task){[self] result in
            switch result {
            case .success:
                print("Completed the task \(task.title)")
            case .failure(let error):
                print("Failed to update task: \(error.localizedDescription)")
                showError(error: error)
            }
        }
    }
    
    func onDelete(for task: TaskDataModel) {
        viewModel.deleteTask(task: task){result in
            switch result {
            case .success:
                print("deleted the task \(task.title)")
            case .failure(let error):
                print("Failed to delete task: \(error.localizedDescription)")
//                showError(error: error)
            }
        }
    }
    
    func setReminder(for task: TaskDataModel) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = "Task Reminder"
                    content.body = task.title
                    content.sound = .default
                    
                    let calendar = Calendar.current
                    let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    
                    let requestIdentifier = "taskReminder_\(task.id)"
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            print("Reminder set successfully for task: \(task.title) at \(task.date)")
                        }
                    }
                } else {
                    print("Notification permission denied.")
                }
            }
        }
    }
}

// MARK: TABLE DELEGATE
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.section].tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as! TaskCell
        cell.configure(with: task)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TaskHeaderView()
        let date = tasks[section].date
        headerView.configure(date: date)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
    // MARK: - Drag and Drop
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            var sourceTasks = tasks[sourceIndexPath.section].tasks
            let movedTask = sourceTasks.remove(at: sourceIndexPath.row)
            tasks[sourceIndexPath.section].tasks = sourceTasks
            
            var destinationTasks = tasks[destinationIndexPath.section].tasks
            destinationTasks.insert(movedTask, at: destinationIndexPath.row)
            tasks[destinationIndexPath.section].tasks = destinationTasks
            
            let calendar = Calendar(identifier: .gregorian)
            
            let originalTime = calendar.dateComponents([.hour, .minute, .second], from: movedTask.date)
            let newDate = tasks[destinationIndexPath.section].date
            let newDateWithOriginalTime = calendar.date(bySettingHour: originalTime.hour ?? 0,
                                                        minute: originalTime.minute ?? 0,
                                                        second: originalTime.second ?? 0,
                                                        of: newDate)!
            viewModel.moveTask(task: movedTask, to: newDateWithOriginalTime)
        } 
        
        tableView.reloadData()
    }

}

extension TaskListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let task = tasks[indexPath.section].tasks[indexPath.row] // Access task directly from the array
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: task.title as NSString))
        dragItem.localObject = task
        return [dragItem]
    }
}


// MARK: Initial Data
private extension TaskListViewController {
    func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "hasLaunchedBefore") {
            return false
        } else {
            // Mark the flag as true for future launches
            defaults.set(true, forKey: "hasLaunchedBefore")
            return true
        }
    }
    
    func insertMockData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let tasksToAdd: [TaskDataModel] = [
            TaskDataModel(
                title: "Stand up meeting",
                descriptionText: "Daily stand up meeting",
                date: calendar.date(bySettingHour: 8, minute: 30, second: 0, of: today) ?? Date(),
                isComplete: true
            ),
            TaskDataModel(
                title: "Register UII",
                descriptionText: "Register the UI interface for the project",
                date: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? Date(),
                isComplete: true
            ),
            TaskDataModel(
                title: "To Do List Mock up",
                descriptionText: "Mock up the to-do list UI",
                date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? Date(),
                isComplete: false
            ),
            TaskDataModel(
                title: "Checkout Mock up",
                descriptionText: "Checkout",
                date: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: today) ?? Date(),
                isComplete: false
            ),
            TaskDataModel(
                title: "Delete Mock up",
                descriptionText: "Delete",
                date: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: today) ?? Date(),
                isComplete: false
            )
        ]
        
        viewModel.addTasks(tasksToAdd) { result in
            switch result {
            case .success:
                print("Tasks added successfully.")
            case .failure(let error):
                print("Failed to add tasks: \(error)")
            }
        }
    }
}
