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
    
    func configure(date: String) {
        dateLabel?.text = date
    }
}

private extension TaskHeaderView {
    private func setupUI() {
        self.backgroundColor = .white
        
        let dateLabel = initDateLabel()
        
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.dateLabel = dateLabel
    }
    
    private func initDateLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }
}
