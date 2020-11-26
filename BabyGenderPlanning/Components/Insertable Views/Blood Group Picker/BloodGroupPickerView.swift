//
//  BloodGroupPickerView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 22.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import PinLayout

final class BloodGroupPickerView: UIView, InsertableView {
    var newStepObservable: Observable<RouteStep> = .empty()
    var dismissObservable: Observable<Void> = .empty()
    
    private let disposeBag = DisposeBag()
    private var gender = Gender.female
    private var bloodGroupId: String = ""
    // MARK: - UI Elements
    
    private lazy var styledView: StyledView = {
        return StyledView()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.generalTextFont.semibold
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Localized.chooseBloodGroup()

        return label
    }()
    
    private lazy var rhesusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.generalTextFont.semibold
        label.textColor = .barossa
        label.numberOfLines = 0
        label.text = Localized.rhesusFactor()

        return label
    }()
    
    private lazy var levelControl: StyledSegmentedControl = {
        let items = ["I", "II", "III", "IV"]
        let themeColor = UIColor.selectedSegmentPink
        let selectedTextColor = UIColor.barossa
        let font = UIFont.titleFont
        
        let control = StyledSegmentedControl(items: items, themeColor: themeColor, selectedTextColor: selectedTextColor, font: font)
        
        return control
    }()
    
    private lazy var rhesusControl: StyledSegmentedControl = {
        let items = ["+", "-"]
        let themeColor = UIColor.selectedSegmentPink
        let selectedTextColor = UIColor.barossa
        let font = UIFont.titleFont
        
        let control = StyledSegmentedControl(items: items, themeColor: themeColor, selectedTextColor: selectedTextColor, font: font)
        
        return control
    }()
    
    private lazy var doneButton: GradientButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.button_done(), for: .normal)
        
        return button
    }()

    private lazy var closeButton = ImageButton(image: Image.unionMin())
    
    // MARK: - Lifecycle

    init(gender: Gender, bloodGroup: BloodGroupInfo?) {
        super.init(frame: .zero)
        self.gender = gender
        self.bloodGroupId = bloodGroup?.id ?? randomUUID

        if let bloodGroup = bloodGroup {
            levelControl.selectedSegmentIndex = bloodGroup.level == 0 ?
                bloodGroup.level :
                bloodGroup.level - 1
            rhesusControl.selectedSegmentIndex = bloodGroup.rhesusFactor == .positive ? 0 : 1
        }
        
        setupBindings()
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

// MARK: - UI Bindings

extension BloodGroupPickerView {
    private func setupBindings() {
        bindDismiss()
        bindNewStep()
    }
    
    private func bindDismiss() {
        let tappedOutsied = rx.tapGesture()
            .when(.recognized)
            .filter { [unowned self] gesture in
                let location = gesture.location(in: self)
                return !self.styledView.frame.contains(location)
            }
            .mapToVoid()
        
        let tappedCloseButton = closeButton.rx.tap.asObservable()
        
        dismissObservable = Observable.merge(tappedOutsied, tappedCloseButton)
    }
    
    private func bindNewStep() {
        let level = levelControl.rx.value.map { $0 + 1 }
        let rhesusFactor = rhesusControl.rx.value
            .map { $0 == 0 ? RhesusFactor.positive : RhesusFactor.negative }
        
        let bloodGroupInfo = Observable.combineLatest(level, rhesusFactor)
            .map { (self.bloodGroupId, $0, $1) }
            .compactMap(BloodGroupInfo.init)
        
        newStepObservable = doneButton.rx.tap
            .withLatestFrom(bloodGroupInfo)
            .map { [unowned self] in ReceivableType.bloodGroup($0, gender: self.gender) }
            .map(RouteStep.dismissAndPass)
    }
}

// MARK: - Layout

extension BloodGroupPickerView {
    func configureLayout() {
        pin.vertically().horizontally()
    }
    
    private func setupSubviews() {
        addSubview(styledView)
        styledView.addSubviews(titleLabel, rhesusLabel, levelControl, rhesusControl, closeButton, doneButton)
    }
    
    private func configureSubviews() {
        styledView.pin
            .vCenter()
            .horizontally(16)
        
        titleLabel.pin
            .height(22)
            .top()
            .horizontally(13)
        
        closeButton.pin
            .size(14)
            .top()
            .right(12)
        
        levelControl.pin
            .height(40)
            .below(of: titleLabel)
            .horizontally(16)
            .marginTop(16)
        
        rhesusLabel.pin
            .height(22)
            .left(16)
            .sizeToFit(.height)
        
        rhesusControl.pin
            .height(40)
            .below(of: levelControl)
            .after(of: rhesusLabel)
            .right(16)
            .marginTop(16)
            .marginLeft(16)
        
        rhesusLabel.pin
            .vCenter(to: rhesusControl.edge.vCenter)
        
        doneButton.pin
            .height(55)
            .below(of: [rhesusControl, rhesusLabel])
            .horizontally(16)
            .marginTop(16)
        
        styledView.pin
            .wrapContent(.vertically, padding: Padding.inset(top: 16, bottom: 16))
    }
}
