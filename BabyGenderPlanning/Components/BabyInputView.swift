//
//  BabyInputView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 15/03/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BabyInputView: StyledView {
    
    // MARK: - Observables
    
    var bornChildData: Observable<BornChildData?> {
        guard let birthdayInput = birthdayDateInputView.customInputView as? DatePickerTextField,
            let numberOfWeeksInput = numberOfWeeksInputView.customInputView as? StyledTextField else {
                return .empty()
        }
        
        let birthdayObservable = birthdayInput.rx.date
        
        let numberOfWeeksObservable = numberOfWeeksInput.rx.text.map { Int($0 ?? "") }
        
        return Observable
            .combineLatest(birthdayObservable.distinctUntilChanged(),
                           numberOfWeeksObservable.distinctUntilChanged())
            .map { birthday, weeks in
                guard let birthday = birthday, let weeks = weeks else { return nil }
                return BornChildData(dateOfBirth: birthday, numberOfWeeks: weeks)
            }
    }
    
    var clearData = PublishRelay<Void>()
    
    private var disposeBag = DisposeBag()

    // MARK: - UI Elements

    private lazy var backgroundImageView: UIImageView = {
        return UIImageView(image: Image.genderSymbols())
    }()

    private lazy var birthdayDateInputView: LabeledInputView = {
        let view = LabeledInputView(inputView: DatePickerTextField(isFutureDateAllowed: false))
        view.label.numberOfLines = 0
        view.label.text = Localized.babyBirthdayDate()

        return view
    }()

    private lazy var numberOfWeeksInputView: LabeledInputView = {
        let textField = StyledTextField(placeholder: Localized.pregnancyDuration_placeholder(),
                                        withToolbar: true)
        textField.keyboardType = .numberPad
        textField.rx.text.orEmpty.map { $0.trim(to: 2) }.bind(to: textField.rx.text).disposed(by: disposeBag)
        
        let view = LabeledInputView(inputView: textField)
        view.label.numberOfLines = 0
        view.label.text = Localized.pregnancyDuration()

        return view
    }()

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
    
    private func setupBindings() {
        guard let birthdayInput = birthdayDateInputView.customInputView as? DatePickerTextField,
            let numberOfWeeksInput = numberOfWeeksInputView.customInputView as? StyledTextField else {
                return
        }
        
        clearData.asObservable().map { return nil }.bind(to: birthdayInput.rx.text, numberOfWeeksInput.rx.text).disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

extension BabyInputView {
    private func setupSubviews() {
        addSubviews(backgroundImageView, birthdayDateInputView, numberOfWeeksInputView)
    }

    private func configureFrames() {
        backgroundImageView.pin
            .left(23)
            .vCenter()
            .sizeToFit()
        
        birthdayDateInputView.pin
            .height(44)
            .top(16)
            .horizontally(12)
        
        numberOfWeeksInputView.pin
            .height(44)
            .below(of: birthdayDateInputView)
            .horizontally(12)
            .marginTop(16)
    }
}
