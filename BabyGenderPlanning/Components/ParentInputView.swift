//
//  ParentInputView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 25/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import PinLayout
import DropDown

class ParentInputView: StyledView {
    
    // MARK: - Observables
    
    var aboutBloodLossTapped: Observable<Void> {
        return bloodLossView.aboutBloodLossTapped
    }
    
    var didTapOnBloodGroup: Observable<BloodGroupInfo?> {
        guard let bloodGroupInput = bloodGroupInputView.customInputView as? BloodGroupTextField else {
            return .empty()
        }
        
        return bloodGroupInput.didTapOnBloodGroup.map { bloodGroupInput.bloodGroup }
    }
    
    var bloodLossDate: Observable<Date?> {
        return bloodLossView.bloodLossDate
    }
    
    var didSelectDropDownAction: Observable<DropDownAction> {
        return didTapOnDropDown.asObservable()
    }
    
    // MARK: - Configuration Elements
    
    var selectedMethod: CalculationMethod = .freymanDobroting {
        didSet {
            updateLayout()
            needToUpdate.accept(())
        }
    }
    
    var birthdayDate = BehaviorRelay<Date?>(value: nil)
    var bloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    var bloodLossDateRelay = BehaviorRelay<Date?>(value: nil)

    var needToUpdate = PublishRelay<Void>()
    private let didTapOnDropDown = PublishRelay<DropDownAction>()
    
    private let disposeBag = DisposeBag()
    
    private var gender: Gender = .female
    
    // MARK: - UI Elements

    private lazy var backgroundImageView: UIImageView = {
        return UIImageView()
    }()

    private(set) lazy var optionsButton = ImageButton(image: Image.dots())

    private lazy var birthdayDateInputView: LabeledInputView = {
        let view = LabeledInputView(inputView: DatePickerTextField(isFutureDateAllowed: false))
        view.label.numberOfLines = 0
        view.label.text = Localized.femaleBirthdayDate()

        return view
    }()

    private lazy var bloodGroupInputView: LabeledInputView = {
        let textField = BloodGroupTextField(placeholder: Localized.bloodGroup())
        textField.isUserInteractionEnabled = false
        
        let view = LabeledInputView(inputView: textField)
        view.label.text = Localized.bloodGroup()

        return view
    }()

    private lazy var motherRhesusFactorInputView: LabeledInputView = {
        let items = ["+", "-"]
        let themeColor = UIColor.selectedSegmentPink
        let selectedTextColor = UIColor.barossa
        let font = UIFont.titleFont

        let control = StyledSegmentedControl(items: items, themeColor: themeColor, selectedTextColor: selectedTextColor, font: font)

        let view = LabeledInputView(inputView: control)
        view.label.text = Localized.rhesusFactor()

        return view
    }()

    private lazy var aboutMotherRhesusFactorLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.text = Localized.mother_about_rhesus_factor()
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var bloodLossView: BloodLossView = {
        let view = BloodLossView()
        view.needToUpdateLayout.bind(to: needToUpdate).disposed(by: disposeBag)
        return view
    }()
    
    private lazy var bottomInset: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.setupDefaultAppearence()
        
        return dropDown
    }()

    private var allViews = [UIView]()

    // MARK: - Lifecycle

    init(gender: Gender) {
        super.init(frame: .zero)
        
        let saveRow = gender == .male ?
            Localized.dropDown_saveFather():
            Localized.dropDown_saveMother()
        
        let items = [Localized.dropDown_chooseSaved(), saveRow]
        
        dropDown.anchorView = self
        dropDown.dataSource = items
        
        self.gender = gender

        let birthdayDateString = gender == .male ?
            Localized.maleBirthdayDate() :
            Localized.femaleBirthdayDate()

        let backgroundImage = gender == .male ?
            Image.maleSymbolSmall() :
            Image.femaleSymbolSmall()

        birthdayDateInputView.label.text = birthdayDateString
        backgroundImageView.image = backgroundImage

        allViews = [backgroundImageView, optionsButton, birthdayDateInputView, bloodGroupInputView, bloodLossView]
        if gender == .female {
            allViews.append(motherRhesusFactorInputView)
            allViews.append(aboutMotherRhesusFactorLabel)
        }
        updateLayout()

        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
    
    func setupBindings() {
        dropDown.selectionAction = { [unowned self] index, _ in
            let action = DropDownAction(rawValue: index) ?? .unknown
            self.didTapOnDropDown.accept(action)
        }
        
        optionsButton.rx.tap.bind(to: dropDown.rx.show).disposed(by: disposeBag)
        
        needToUpdate
            .asVoidDriver()
            .drive(onNext: { [unowned self] in self.updateLayout() })
            .disposed(by: disposeBag)
        
        birthdayDate
            .subscribe(onNext: { [unowned self] date in
                let firstRow = Localized.dropDown_chooseSaved()
                guard date != nil else {
                    self.dropDown.dataSource = [firstRow]
                    return
                }
                
                let secondRow = self.gender == .male ?
                    Localized.dropDown_saveFather():
                    Localized.dropDown_saveMother()
                
                self.dropDown.dataSource = [firstRow, secondRow]
            })
            .disposed(by: disposeBag)
        
        guard let birthdayDateInput = birthdayDateInputView.customInputView as? DatePickerTextField,
            let bloodGroupInput = bloodGroupInputView.customInputView as? BloodGroupTextField,
            let motherRhesusFactorInput = motherRhesusFactorInputView.customInputView as? StyledSegmentedControl else {
                return
        }
        bloodLossDateRelay.bind(to: bloodLossView.loadedBloodLossDate).disposed(by: disposeBag)
        (birthdayDate <-> birthdayDateInput.rx.date).disposed(by: disposeBag)
        (bloodGroup <-> bloodGroupInput.rx.bloodGroup).disposed(by: disposeBag)

        bloodGroup
            .compactMap { $0 }
            .map { $0.rhesusFactor == RhesusFactor.positive ? 0 : 1 }
            .bind(to: motherRhesusFactorInput.rx.value)
            .disposed(by: disposeBag)

        motherRhesusFactorInput.rx.value
            .map { $0 == 0 ? RhesusFactor.positive : RhesusFactor.negative }
            .map { [weak self] in self?.getBloodGroupInfo(rhesusFactor: $0) }
            .bind(to: bloodGroup)
            .disposed(by: disposeBag)
    }

    func getBloodGroupInfo(rhesusFactor: RhesusFactor) -> BloodGroupInfo {
        if var bloodGroup = bloodGroup.value {
            bloodGroup.rhesusFactor = rhesusFactor
            return bloodGroup
        } else {
            return BloodGroupInfo(id: "", level: 0, rhesusFactor: rhesusFactor)
        }
    }
}

// MARK: - Layout

extension ParentInputView {
    private func updateLayout() {
        updateBackgroundImage()
        setupSubviews()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        switch selectedMethod {
        case .freymanDobroting:
            removeSubviews(allViews)
            addSubviews(optionsButton, backgroundImageView, birthdayDateInputView)
        case .bloodRenewal:
            addSubviews(allViews)
        }
    }
    
    private func configureFrames() {
        backgroundImageView.pin.top().size(0)

        optionsButton.pin
            .height(7)
            .width(27)
            .top()
            .right(17)

        birthdayDateInputView.pin
            .height(44)
            .below(of: optionsButton)
            .horizontally(12)
            .marginTop(20)

        guard selectedMethod == .bloodRenewal else {
            pin.wrapContent(.vertically, padding: Padding.inset(top: 17, bottom: 44))

            backgroundImageView.pin
                .left(64)
                .vCenter(to: birthdayDateInputView.edge.vCenter)
                .sizeToFit()

            return
        }

        bloodGroupInputView.pin
            .height(44)
            .below(of: birthdayDateInputView)
            .horizontally(12)
            .marginTop(16)

        if gender == .female {
            motherRhesusFactorInputView.pin
                .height(44)
                .below(of: bloodGroupInputView)
                .horizontally(12)
                .marginTop(16)

            aboutMotherRhesusFactorLabel.pin
                .sizeToFit(.width)
                .below(of: motherRhesusFactorInputView)
                .horizontally(12)
                .marginTop(12)

            bloodLossView.pin
                .below(of: aboutMotherRhesusFactorLabel)
                .horizontally(12)
                .marginTop(12)
        } else {
            bloodLossView.pin
                .below(of: bloodGroupInputView)
                .horizontally(12)
                .marginTop(28)
        }

        pin.wrapContent(.vertically, padding: Padding.inset(top: 17, bottom: 24))

        backgroundImageView.pin
            .left(23)
            .vCenter(to: bloodGroupInputView.edge.vCenter)
            .sizeToFit()
    }
}

private extension ParentInputView {
    func updateBackgroundImage() {
        switch selectedMethod {
        case .freymanDobroting:
            backgroundImageView.image = gender == .male ?
                Image.maleSymbolSmall() :
                Image.femaleSymbolSmall()
            
        case .bloodRenewal:
            backgroundImageView.image = gender == .male ?
                Image.maleSymbol() :
                Image.femaleSymbol()
        }
    }
}

extension Reactive where Base: DropDown {
    var show: Binder<Void> {
        return Binder(base) { view, _ in
            view.mirror()
            view.show()
        }
    }
}

extension DropDown {
    func mirror() {
        layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
        
        for view in subviews {
                    
            for view in view.subviews {
                view.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
            }
        }
    }
    
    func setupDefaultAppearence() {
        selectionBackgroundColor = .white
        backgroundColor = .white
        cornerRadius = Constants.styledViewCornerRadius
        shadowOpacity = 1
        shadowColor = .viewShadow
        shadowOffset = CGSize(width: 0, height: 6)
        shadowRadius = 10
        width = 230
        textColor = .barossa
        textFont = .generalTextFont
    }
}
