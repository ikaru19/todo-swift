//
//  AddTaskViewController.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import Foundation
import UIKit
import SnapKit

class AddTaskViewController: UIViewController {
    private var titleTextField: UITextField?
    private var descriptionTextField: UITextView?
    private var dateTextField: UITextField?
    private var timeTextField: UITextField?
    
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    private var selectedDate: Date?
    private var selectedTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        configurePickers()
    }
    
    private func setupNavigation() {
        view.backgroundColor = .white
        navigationItem.title = "Add Task"
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func didTapSaveButton() {
        guard let title = titleTextField?.text, !title.isEmpty,
              let date = selectedDate,
              let time = selectedTime else {
            print("All fields must be filled.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: time),
                                                     minute: Calendar.current.component(.minute, from: time),
                                                     second: 0,
                                                     of: date)
        
        let finalDateString = formatter.string(from: combinedDateTime ?? date)
        print("Title: \(title), Date-Time: \(finalDateString)")
    }
}

// MARK: - UI Setup
private extension AddTaskViewController {
    private func setupUI() {
        let titleLabel = initLabel(text: "Title")
        let titleTextField = initTextField(placeholder: "Enter task title")
        
        let descriptionLabel = initLabel(text: "Description")
        let descriptionTextField = createTextView(placeholder: "Description Task")
        
        let dateLabel = initLabel(text: "Date")
        let dateTextField = initTextField(placeholder: "Select date")
        
        let timeLabel = initLabel(text: "Time")
        let timeTextField = initTextField(placeholder: "Select time")
        
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionTextField)
        view.addSubview(dateLabel)
        view.addSubview(dateTextField)
        view.addSubview(timeLabel)
        view.addSubview(timeTextField)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        timeTextField.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        self.titleTextField = titleTextField
        self.descriptionTextField = descriptionTextField
        self.dateTextField = dateTextField
        self.timeTextField = timeTextField
    }
    
    private func initLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }
    
    private func createTextView(placeholder: String) -> UITextView {
        let textView = UITextView()
        textView.text = placeholder
        textView.textColor = .lightGray
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.delegate = self // To handle placeholder behavior
        return textView
    }
    
    private func initTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.tintColor = .clear
        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        return textField
    }
}

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter task description"
            textView.textColor = .lightGray
        }
    }
}


// MARK: - Configure Pickers
private extension AddTaskViewController {
    private func configurePickers() {
        // Configure Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        configurePicker(datePicker, for: dateTextField)
        
        // Configure Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        configurePicker(timePicker, for: timeTextField)
    }
    
    private func configurePicker(_ picker: UIDatePicker, for textField: UITextField?) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Cancel Button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPickerTapCancelButton))
        
        // Flexible Space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done Button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        
        // Add buttons to the toolbar
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        
        textField?.inputView = picker
        textField?.inputAccessoryView = toolbar
    }
    
    @objc private func didPickerTapCancelButton() {
        // Dismiss the picker without saving changes
        view.endEditing(true)
    }
    
    @objc private func didTapDoneButton() {
        if dateTextField?.isFirstResponder == true {
            selectedDate = datePicker.date
            dateTextField?.text = formattedDateDescription(for: datePicker.date)
        } else if timeTextField?.isFirstResponder == true {
            selectedTime = timePicker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeTextField?.text = formatter.string(from: timePicker.date)
        }
        
        view.endEditing(true)
    }
    
    private func formattedDateDescription(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: date)
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "\(dateString) (Today)"
        } else if calendar.isDateInTomorrow(date) {
            return "\(dateString) (Tomorrow)"
        } else {
            return dateString
        }
    }
}

