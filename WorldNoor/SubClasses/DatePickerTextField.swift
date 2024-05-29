//
//  DatePickerTextField.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 13/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class DatePickerTextField: UITextField {
    
    // MARK: - Lazy Properties -
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        // Configure date picker mode
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        return toolbar
    }()
    
    // MARK: - Life Cycle -
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDatePicker()
        updateTextFieldWithDate(date: Date()) // Update the text field when the view loads
    }
    
    // MARK: - Methods -
    private func setupDatePicker() {
        // Set date picker as input view
        self.inputView = datePicker
        // Set toolbar as input accessory view
        self.inputAccessoryView = toolbar
    }
    
    @objc private func didTapDone() {
        updateTextFieldWithDate(date: datePicker.date)
        self.resignFirstResponder()
    }
    
    private func updateTextFieldWithDate(date: Date) {
        self.text = formatter.string(from: date)
    }
}
