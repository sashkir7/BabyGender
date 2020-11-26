//
//  EstimatedConceptionDateView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 15/03/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PinLayout

class EstimatedConceptionDateView: StyledView {

    // MARK: - Observables
    
    var conceptionDate: Observable<Date?> {
        return dateTextField.rx.date.asObservable()
    }
    
    // MARK: - UI Elements

    private lazy var topPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = UIColor.barossa.withAlphaComponent(0.4)
        label.text = Localized.estimatedConceptionDate()

        return label
    }()

    private(set) lazy var dateTextField: DatePickerTextField = {
        let textField = DatePickerTextField()
        textField.textColor = .barossa
        textField.backgroundColor = .clear
        textField.textAlignment = .left

        return textField
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .appWhite
        layer.cornerRadius = 16

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
}

// MARK: - Layout

extension EstimatedConceptionDateView {
    private func setupSubviews() {
        addSubviews(topPlaceholderLabel, dateTextField)
    }

    private func configureSubviews() {
        topPlaceholderLabel.pin
            .top(8)
            .left(11)
            .sizeToFit()
        
        dateTextField.pin
            .top(5)
            .bottom()
            .horizontally(12)
    }
}
