//
//  TaskCell.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import UIKit
import SnapKit

protocol TaskCellDelegate: AnyObject {
    func onDelete(for task: TaskDataModel)
    func setReminder(for task: TaskDataModel)
    func onCompleteUpdated(for task: TaskDataModel)
}

class TaskCell: UITableViewCell {
    static let identifier = "TaskCell"
    private var titleLabel: UILabel?
    private var timeLabel: UILabel?
    private var checkBox: UIButton?
    private var task: TaskDataModel?
    
    weak var delegate: TaskCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        initEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with task: TaskDataModel) {
        self.task = task
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" 
        let formattedTime = formatter.string(from: task.date)
        timeLabel?.text = formattedTime
        checkBox?.isSelected = task.isComplete
        
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: task.isComplete ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: UIColor.red
        ]
        let titleText = task.title
        self.titleLabel?.attributedText = NSAttributedString(string: titleText, attributes: attributes)

    }
    
    @objc private func didTapCheckBox() {
        guard let task = task else { return }
        delegate?.onCompleteUpdated(for: task)
        checkBox?.isSelected = task.isComplete
        animateTaskCompletion()
    }
    
    private func animateTaskCompletion() {
        UIView.animate(withDuration: 0.3) {
            // Adjusting the alpha for the fade-out effect
            let isChecked = self.checkBox?.isSelected ?? false
            self.titleLabel?.alpha = isChecked ? 0.5 : 1
            self.timeLabel?.alpha = isChecked ? 0.5 : 1
            
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: isChecked ? NSUnderlineStyle.single.rawValue : 0,
                .strikethroughColor: UIColor.red
            ]
            let titleText = self.titleLabel?.text ?? ""
            self.titleLabel?.attributedText = NSAttributedString(string: titleText, attributes: attributes)
        }
    }
    
    private func initEvents() {
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
}



// MARK: - UIContextMenuInteractionDelegate
extension TaskCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let task = task else { return nil }
        
        let reminderAction = UIAction(title: "Set Reminder", image: UIImage(systemName: "bell")) { action in
            self.delegate?.setReminder(for: task)
        }
        
        let deleteAction = UIAction(title: "Delete Task", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            self.delegate?.onDelete(for: task)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [reminderAction, deleteAction])
        }
    }
}


private extension TaskCell {
    private func setupUI() {
        let titleLabel = initTitleLabel()
        let timeLabel = initTimeLabel()
        let checkBox = initCheckBox()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(checkBox)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(15)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(contentView).offset(15)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        checkBox.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-15)
        }
        
        self.titleLabel = titleLabel
        self.timeLabel = timeLabel
        self.checkBox = checkBox
    }
    
    private func initTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func initTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func initCheckBox() -> UIButton {
        let checkBox = UIButton(type: .custom)
        checkBox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        return checkBox
    }
}
