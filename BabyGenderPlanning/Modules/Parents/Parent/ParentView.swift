//
//  ParentView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ParentView: UIView {
    private let presenter: ParentPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        let headerView = HeaderTitleView(title: Localized.parent_screen_title(), isBackButton: true)
        
        return headerView
    }()
    
    private(set) lazy var parentNameTextField: PaddingTextField = {
        let textField = PaddingTextField(placeholder: Localized.parentName())
        textField.textAlignment = .left
        textField.layer.cornerRadius = 4
        textField.disableShadow()
        return textField
    }()
    
    private lazy var genderButton = StyledGenderButton()
    
    private lazy var chooseGenderInputView: LabeledInputView = {
        let view = LabeledInputView(inputView: genderButton)
        view.label.text = Localized.chooseParentGender()
        view.label.numberOfLines = 0

        return view
    }()
    
    private lazy var birthdayDatePicker: DatePickerTextField = {
        let textField = DatePickerTextField(isFutureDateAllowed: false)
        textField.disableShadow()
        
        return textField
    }()
    
    private lazy var birthdayDateInputView: LabeledInputView = {
        let view = LabeledInputView(inputView: birthdayDatePicker)
        view.label.text = Localized.birthdayDate()

        return view
    }()

    private lazy var bloodGroupTextField = BloodGroupTextField(placeholder: Localized.bloodGroup())
    
    private lazy var bloodGroupInputView: LabeledInputView = {
        let textField = bloodGroupTextField
        textField.disableShadow()
        let view = LabeledInputView(inputView: textField)
        view.label.text = Localized.bloodGroup()

        return view
    }()

    private lazy var bloodLossView: BloodLossView = {
        return BloodLossView(disableShadow: true)
    }()
        
    private lazy var saveButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.buttonSave(), for: .normal)

        return button
    }()
    
    // MARK: - Init
    
    init(_ presenter: ParentPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
        
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(colors: .pink)
        configureSubviews()
    }
}

// MARK: - UI Bindings

extension ParentView {
    private func setupBindings() {
        let input = ParentPresenter.Input(
            backTrigger: headerView.menuButton.rx.tap.asObservable(),
            saveTrigger: saveButton.rx.tap.asObservable(),
            name: parentNameTextField.rx.text.asObservable(),
            gender: genderButton.rx.gender.asObservable(),
            birthdayDate: birthdayDatePicker.rx.date.asObservable(),
            bloodGroup: bloodGroupTextField.rx.bloodGroup.asObservable(),
            bloodLossDate: bloodLossView.bloodLossDate,
            didTapBloodGroup: bloodGroupTextField.didTapOnBloodGroup,
            didTapAboutBloodLoss: bloodLossView.aboutBloodLossTapped
        )
        
        let output = presenter.buildOutput(with: input)
        
        output.gender.drive(genderButton.rx.gender).dispose()
        output.birthdayDate.drive(birthdayDatePicker.rx.date).dispose()
        output.bloodLossDate.drive(bloodLossView.loadedBloodLossDate).dispose()
        
        disposeBag.insert(
            output.bloodGroup.drive(bloodGroupTextField.rx.bloodGroup),
            output.name.drive(parentNameTextField.rx.text),
            output.showNameBorder.drive(parentNameTextField.rx.showBorder),
            output.showBirthdayDateBorder.drive(birthdayDatePicker.rx.showBorder),
            output.showBloodLossDateBorder.drive(bloodLossView.rx.showDatePickerBorder),
            output.message.drive(rx.toastMessage)
        )
    }
}

// MARK: - Private Methods

extension ParentView {
    private func setupSubviews() {
        addSubviews(headerView, parentNameTextField)
        addSubviews(chooseGenderInputView, birthdayDateInputView)
        addSubviews(bloodGroupInputView, bloodLossView, saveButton)
    }

    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        parentNameTextField.pin
            .height(44)
            .below(of: headerView)
            .horizontally(12)
        
        chooseGenderInputView.pin
            .height(44)
            .below(of: parentNameTextField)
            .horizontally(12)
            .marginTop(16)
        
        birthdayDateInputView.pin
            .height(44)
            .below(of: chooseGenderInputView)
            .horizontally(12)
            .marginTop(16)

        bloodGroupInputView.pin
            .height(44)
            .below(of: birthdayDateInputView)
            .horizontally(12)
            .marginTop(16)
        
        bloodLossView.pin
            .below(of: bloodGroupInputView)
            .horizontally(12)
            .marginTop(28)

        saveButton.pin
            .height(55)
            .width(275)
            .hCenter()
            .bottom(32)
    }
}
