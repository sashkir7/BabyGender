//
//  StyledTextField.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class StyledTextField: UITextField {

    private var placeholderColor: UIColor {
        return UIColor.textPrimary.withAlphaComponent(0.4)
    }

    // MARK: - Lifecycle

    init(placeholder: String, withToolbar: Bool = false) {
        super.init(frame: .zero)

        layer.cornerRadius = Constants.styledViewCornerRadius
        textAlignment = .center

        textColor = .textPrimary

        let font = UIFont.generalTextFont
        self.font = font
        attributedPlaceholder = .init(placeholder, font: font, textColor: placeholderColor)

        applyShadow()
        
        guard withToolbar else { return }
        setupTextFieldInputView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func disableShadow() {
        layer.shadowOpacity = 0
    }
}

extension StyledTextField {
    private func applyShadow() {
        backgroundColor = UIColor.white
        layer.masksToBounds = false
        layer.shadowColor = UIColor.textFieldShadow.cgColor
        layer.shadowRadius = 18
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    private func setupTextFieldInputView() {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: Localized.button_done(), style: .plain, target: self, action: #selector(done))
        toolBar.setItems([flexible, doneButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    @objc private func done() {
        resignFirstResponder()
    }
}
