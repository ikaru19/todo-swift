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
    
    private var tasks: [(date: Date, tasks: [Task])] = []
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                
                for (index, oldSection) in oldTasks.enumerated() {
                    if !newTasks.contains(where: { $0.date == oldSection.date }) {
                        deletedSections.insert(index)
                    }
                }
                
                for (index, newSection) in newTasks.enumerated() {
                    if !oldTasks.contains(where: { $0.date == newSection.date }) {
                        insertedSections.insert(index)
                    }
                }
                
                for (index, newSection) in newTasks.enumerated() {
                    if let oldSectionIndex = oldTasks.firstIndex(where: { $0.date == newSection.date }) {
                        let oldSection = oldTasks[oldSectionIndex]
                        if oldSection.tasks != newSection.tasks {
                            if !deletedSections.contains(oldSectionIndex) {
                                reloadedSections.insert(oldSectionIndex)
                            }
                        }
                    }
                }
                
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
    
    @objc private func didTapAddButton() {
        print("Add Task button tapped")
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
    func onCompleteUpdated(for task: Task) {
        viewModel.toggleTaskCompletion(for: task)
    }
    
    func onDelete(for task: Task) {
        viewModel.deleteTask(task: task)
    }
    
    func setReminder(for task: Task) {
        print("on set reminder")
        print("on set reminder \(task.date)")
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
        if sourceIndexPath.section == destinationIndexPath.section {
            var tasksInSection = tasks[sourceIndexPath.section].tasks
            let movedTask = tasksInSection.remove(at: sourceIndexPath.row)
            tasksInSection.insert(movedTask, at: destinationIndexPath.row)
            tasks[sourceIndexPath.section].tasks = tasksInSection
        } else {
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
