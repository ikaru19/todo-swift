//
//  TaskHeaderView.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import SnapKit
import UIKit

class TaskHeaderView: UIView {
    
    private var dateLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(date: Date) {
        let dateFormatter = DateFormatter()
        let weekdayFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd MMMM yyyy" // Format like "05 January 2025"
        weekdayFormatter.dateFormat = "EEE" // Format for weekday abbreviation (Mon, Tue, Wed, etc.)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            dateLabel?.text = "Today (\(dateFormatter.string(from: date)))"
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            dateLabel?.text = "Tomorrow (\(dateFormatter.string(from: date)))"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            dateLabel?.text = "Yesterday (\(dateFormatter.string(from: date)))"
        } else {
            let weekday = weekdayFormatter.string(from: date)
            dateLabel?.text = "\(weekday) (\(dateFormatter.string(from: date)))"
        }
    }
}

private extension TaskHeaderView {
    private func setupUI() {
        self.backgroundColor = .systemBlue
        
        let dateLabel = initDateLabel()
        
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        self.dateLabel = dateLabel
    }
    
    private func initDateLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }
}
