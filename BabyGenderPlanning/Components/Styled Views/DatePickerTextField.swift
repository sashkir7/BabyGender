//
//  DatePickerTextField.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 04.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DatePickerTextField: StyledTextField {

    var isFutureDateAllowed: Bool = false {
        didSet {
            datePicker.maximumDate = isFutureDateAllowed ? nil : Date()
        }
    }

    var date: Date? {
        didSet {
            guard let date = date else {
                text = nil
                datePicker.date = Date()
                return
            }
            text = date.format(dateFormat: .ddMMYYYY)
            datePicker.date = date
        }
    }

    private(set) lazy var datePicker: UIDatePicker = {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    init(isFutureDateAllowed: Bool = true) {
        super.init(placeholder: Localized.dateFormat())

        self.isFutureDateAllowed = isFutureDateAllowed
        datePicker.maximumDate = isFutureDateAllowed ? nil : Date()
        setupDatePickerInputView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDatePickerInputView() {
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: datePicker.frame.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.button_cancel(), style: .plain, target: self, action: #selector(cancel))
        let doneButton = UIBarButtonItem(title: Localized.button_done(), style: .plain, target: self, action: #selector(doneSelected))
        toolBar.setItems([cancelButton, flexible, doneButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc private func cancel() {
        self.resignFirstResponder()
    }
        
    @objc private func doneSelected() {
        date = datePicker.date
        self.resignFirstResponder()
    }
}

extension Reactive where Base: DatePickerTextField {
    var date: ControlProperty<Date?> {
        return value
    }

    /// Reactive wrapper for `date` property.
    var value: ControlProperty<Date?> {
        return base.rx.controlProperty(editingEvents: .allEditingEvents,
                                       getter: { view in
                                           view.date
                                       },
                                       setter: { view, date in
                                           view.date = date
                                       })
    }
}
