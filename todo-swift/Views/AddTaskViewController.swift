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
    private let viewModel: TaskListViewModel
    
    private var titleTextField: UITextField?
    private var descriptionTextField: UITextView?
    private var dateTextField: UITextField?
    private var timeTextField: UITextField?
    
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    private var selectedDate: Date?
    private var selectedTime: Date?
    
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
        setupEvents()
    }
    
    private func setupEvents() {
        configurePickers()
        observeTitleTextFieldChanges()
    }
    
    private func setupNavigation() {
        view.backgroundColor = .white
        navigationItem.title = "Add Task"
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func updateTitleTextFieldForToday() {
        guard let titleText = titleTextField?.text else { return }
        
        let range = (titleText as NSString).range(of: "today", options: .caseInsensitive)
        
        let defaultAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        
        let attributedText = NSMutableAttributedString(string: titleText, attributes: defaultAttribute)
        
        if range.location != NSNotFound {
            if selectedDate == nil || Calendar.current.isDateInToday(selectedDate!) {
                attributedText.addAttribute(.foregroundColor, value: UIColor.purple, range: range)
            }
        }
        
        titleTextField?.attributedText = attributedText
    }
    
    
    func showError(message: String, forField field: UITextField?, tag: Int) {
        guard let field = field else { return }
        
        if field.viewWithTag(tag) == nil {
            let errorLabel = UILabel()
            errorLabel.text = message
            errorLabel.textColor = .red
            errorLabel.font = UIFont.systemFont(ofSize: 12)
            errorLabel.tag = tag
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            
            field.superview?.addSubview(errorLabel)
            
            errorLabel.snp.makeConstraints { make in
                make.top.equalTo(field.snp.bottom).offset(4)
                make.leading.equalTo(field.snp.leading)
            }
        }
    }
    
    func hideError(tag: Int) {
        if let errorLabel = view.viewWithTag(tag) {
            errorLabel.removeFromSuperview()
        }
    }
    
    @objc private func titleTextFieldDidChange() {
        guard let titleText = titleTextField?.text else { return }
        
        let range = (titleText as NSString).range(of: "today", options: .caseInsensitive)
        
        let defaultAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        let attributedText = NSMutableAttributedString(string: titleText, attributes: defaultAttribute)
        
        if range.location != NSNotFound {
            attributedText.addAttribute(.foregroundColor, value: UIColor.purple, range: range)
            
            selectedDate = Date()
            dateTextField?.text = formattedDateDescription(for: selectedDate ?? Date())
        }
        
        titleTextField?.attributedText = attributedText
    }
    
    
    private func observeTitleTextFieldChanges() {
        titleTextField?.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func didTapSaveButton() {
        var isValid = true
        
        if let title = titleTextField?.text, title.isEmpty {
            titleTextField?.layer.borderColor = UIColor.red.cgColor
            showError(message: "Title is required.", forField: titleTextField, tag: 1001)
            isValid = false
        } else {
            titleTextField?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            hideError(tag: 1001)
        }
        
        if selectedDate == nil {
            dateTextField?.layer.borderColor = UIColor.red.cgColor
            showError(message: "Date is required.", forField: dateTextField, tag: 1002)
            isValid = false
        } else {
            dateTextField?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            hideError(tag: 1002)
        }
        
        if selectedTime == nil {
            timeTextField?.layer.borderColor = UIColor.red.cgColor
            showError(message: "Time is required.", forField: timeTextField, tag: 1003)
            isValid = false
        } else {
            timeTextField?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            hideError(tag: 1003)
        }
        
        if !isValid {
            print("All fields must be filled.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime!),
                                                     minute: Calendar.current.component(.minute, from: selectedTime!),
                                                     second: 0,
                                                     of: selectedDate!)
        
        let finalDateString = formatter.string(from: combinedDateTime ?? selectedDate!)
        if let title = titleTextField?.text, let description = descriptionTextField?.text {
            viewModel.addTask(title: title, description: description, date: selectedDate!, time: combinedDateTime ?? selectedDate!)
            print("Task added successfully!")
        }
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

// MARK: - Configure Pickers
private extension AddTaskViewController {
    private func configurePickers() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        configurePicker(datePicker, for: dateTextField)
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        configurePicker(timePicker, for: timeTextField)
    }
    
    private func configurePicker(_ picker: UIDatePicker, for textField: UITextField?) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPickerTapCancelButton))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        
        textField?.inputView = picker
        textField?.inputAccessoryView = toolbar
    }
    
    @objc private func didPickerTapCancelButton() {
        view.endEditing(true)
    }
    
    @objc private func didTapDoneButton() {
        if dateTextField?.isFirstResponder == true {
            // Update the selected date
            selectedDate = datePicker.date
            
            // Update the dateTextField with the formatted date description
            dateTextField?.text = formattedDateDescription(for: datePicker.date)
            
            // Update the titleTextField's attributed text
            updateTitleTextFieldForToday()
        } else if timeTextField?.isFirstResponder == true {
            // Update the selected time
            selectedTime = timePicker.date
            
            // Format and update the timeTextField with the selected time
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

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Only apply this to the descriptionTextField (UITextView)
        if textView == descriptionTextField && textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Only apply this to the descriptionTextField (UITextView)
        if textView == descriptionTextField && textView.text.isEmpty {
            textView.text = "Enter task description"
            textView.textColor = .lightGray
        }
    }
}
