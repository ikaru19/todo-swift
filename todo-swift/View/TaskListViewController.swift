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

struct Task {
    var title: String
    var date: String
    var time: String
    var isCompleted: Bool
}

class TaskListViewController: UIViewController {
    var tasks: [String: [Task]] = [
        "2025-01-09": [
            Task(
                title: "Task 1",
                date: "2025-01-09",
                time: "08:20",
                isCompleted: false),
            Task(
                title: "Task 2",
                date: "2025-01-09",
                time: "09:30",
                isCompleted: false)
        ],
        "2025-01-10": [
            Task(
                title: "Task 3",
                date: "2025-01-10",
                time: "10:30",
                isCompleted: false
            )
        ]
    ]
    
    private var tableView: UITableView?
    private var addButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        setupTable()
    }
    
    private func setupNavigation() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"
        let addButton = UIBarButtonItem(title: "Add Task", style: .plain, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func didTapAddButton() {
        // Logic for adding a new task
        print("Add Task button tapped")
        let vc = AddTaskViewController()
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
    func onDelete(for task: Task) {
        print("on Delete")
    }
    
    func setReminder(for task: Task) {
        print("on set reminder")
    }
}

// MARK: TABLE DELEGATE
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = Array(tasks.keys)[section]
        return tasks[sectionKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionKey = Array(tasks.keys)[indexPath.section]
        guard let task = tasks[sectionKey]?[indexPath.row] else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as! TaskCell
        cell.configure(with: task)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TaskHeaderView()
        let sectionKey = Array(tasks.keys)[section]
        headerView.configure(date: sectionKey)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: - Drag and Drop
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let sectionKeyFrom = Array(tasks.keys)[fromIndexPath.section]
        let sectionKeyTo = Array(tasks.keys)[to.section]
        
        if sectionKeyFrom == sectionKeyTo {
            var taskArray = tasks[sectionKeyFrom]!
            let movedTask = taskArray.remove(at: fromIndexPath.row)
            taskArray.insert(movedTask, at: to.row)
            tasks[sectionKeyFrom] = taskArray
        } else {
            var taskArrayFrom = tasks[sectionKeyFrom]!
            let movedTask = taskArrayFrom.remove(at: fromIndexPath.row)
            tasks[sectionKeyFrom] = taskArrayFrom
            
            var taskArrayTo = tasks[sectionKeyTo]!
            taskArrayTo.insert(movedTask, at: to.row)
            tasks[sectionKeyTo] = taskArrayTo
        }
    }
}

extension TaskListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let sectionKey = Array(tasks.keys)[indexPath.section]
        guard let task = tasks[sectionKey]?[indexPath.row] else {
            return []
        }
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: task.title as NSString))
        dragItem.localObject = task
        return [dragItem]
    }
}
