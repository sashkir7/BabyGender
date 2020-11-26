//
//  GenderPlanningView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PinLayout

final class GenderPlanningView: UIView {
    private let presenter: GenderPlanningPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.page_title_genderPlanning(), isBackButton: true)
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubviews(scrollContentView)

        return scrollView
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.addSubviews(segmentedControl, disclaimerContainer, aboutMethodButton, genderSelector, parentsInputView)
        view.addSubviews(conceptionPeriodSelector, calculateButton, planningView)
        return view
    }()
    private lazy var disclaimerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.sundown()?.withAlphaComponent(0.1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        view.addSubview(disclaimerLabel)
        return view
    }()
    private lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = R.color.textPrimary()
        label.textAlignment = .center
        label.text = Localized.disclaimer()
        label.numberOfLines = 0
        return label
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentItems = getCalculateMethodTitles()
        return StyledSegmentedControl(items: segmentItems)
    }()

    private lazy var aboutMethodButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.mulberry, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.setTitle(Localized.aboutMethod(), for: .normal)
        return button
    }()
    
    private lazy var genderSelector: BabyGenderSelector = {
        let selector = BabyGenderSelector()
        
        return selector
    }()
    
    private lazy var parentsInputView: ParentsInputView = {
        let view = ParentsInputView()
        return view
    }()
    
    private lazy var conceptionPeriodSelector = ConceptionPeriodSelector()
    
    private lazy var calculateButton: GradientButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.calculate_button_title(), for: .normal)
        
        return button
    }()
    
    private lazy var planningView = PlanningResultView()
    
    // MARK: - Lifecycle

    init(_ presenter: GenderPlanningPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)

        backgroundColor = .appWhite

        setupSubviews()
        setupBindings()
        updateLayout()
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

extension GenderPlanningView {
    private func setupBindings() {
        headerView.menuButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let input = GenderPlanningPresenter.Input(
            backTrigger: headerView.menuButton.rx.tap.asObservable(),
            needToUpdateLayout: parentsInputView.needToUpdate.asObservable(),
            
            fatherBirthdayDate: parentsInputView.fatherBirthdayDate,
            fatherBloodGroup: parentsInputView.fatherBloodGroup,
            fatherBloodLossDate: parentsInputView.fatherBloodLossDate,
            motherBirthdayDate: parentsInputView.motherBirthdayDate,
            motherBloodGroup: parentsInputView.motherBloodGroup,
            motherBloodLossDate: parentsInputView.motherBloodLossDate,
            
            fatherDropDownAction: parentsInputView.fatherDropDownAction,
            motherDropDownAction: parentsInputView.motherDropDownAction,
            
            conceptionPeriod: conceptionPeriodSelector.conceptionPeriodInMonth,
            babyGender: genderSelector.genderChanged,
            
            didSwitchCalculationMethod: segmentedControl.rx.value.asObservable(),
            didTapOnAboutFemaleBloodLoss: parentsInputView.showFemaleAboutBloodLoss,
            didTapOnAboutMaleBloodLoss: parentsInputView.showMaleAboutBloodLoss,
            didTapOnCalculateButton: calculateButton.rx.tap.asObservable(),
            didTapOnFemaleBloodGroup: parentsInputView.showFemaleBloodGroupPicker,
            didTapOnMaleBloodGroup: parentsInputView.showMaleBloodGroupPicker,
            didTapAboutMethod: aboutMethodButton.rx.tap.asObservable(),
            didTapOnRecommendations: planningView.didTapTipsButton
        )
        
        let output = presenter.buildOutput(with: input)
        
        disposeBag.insert(
            output.updateMenuButtonImage.drive(headerView.rx.menuButtonImage),
            output.selectedMethod.drive(parentsInputView.selectedMethod),
            output.loadedMother.drive(parentsInputView.loadedMother),
            output.loadedFather.drive(parentsInputView.loadedFather),
            output.fatherBloodGroup.drive(parentsInputView.setFatherBloodGroup),
            output.motherBloodGroup.drive(parentsInputView.setMotherBloodGroup),
            output.shouldScrollToBottom.drive(scrollView.rx.scrollToBottom),
            output.planningResult.drive(planningView.rx.planning),
            output.message.drive(rx.toastMessage),
            output.updateLayout.drive(onNext: { [unowned self] in self.updateLayout() })
        )
    }
}

// MARK: - Private Methods

extension GenderPlanningView {
    private func getCalculateMethodTitles() -> [String] {
        return UIScreen.main.bounds.width > 320 ?
            [Localized.freymanDobrotingMethod(), Localized.bloodRenewalMethod()] :
            [Localized.freymanDobrotingMethod_short(), Localized.bloodRenewalMethod()]
    }

    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubviews(headerView, scrollView)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()

        scrollView.pin
            .below(of: headerView)
            .bottom()
            .horizontally()
        
        scrollContentView.pin
            .vertically()
            .horizontally(16)
        
        segmentedControl.pin
            .top()
            .horizontally()
        
        disclaimerContainer.pin.below(of: segmentedControl).marginTop(16).left(16).right(16)
        disclaimerLabel.pin.all(11).sizeToFit(.width)
        disclaimerContainer.pin.wrapContent(padding: 11)
        
        aboutMethodButton.pin
            .below(of: disclaimerContainer)
            .right()
            .marginTop(8)
            .sizeToFit()
        
        genderSelector.pin
            .below(of: aboutMethodButton)
            .horizontally()
            .marginTop(16)
            .wrapContent(.vertically)
        
        parentsInputView.pin
            .below(of: genderSelector)
            .horizontally()
            .marginTop(10)
            .wrapContent(.vertically)
        
        conceptionPeriodSelector.pin
            .below(of: parentsInputView)
            .horizontally()
            .marginTop(24)
            .wrapContent(.vertically)
        
        calculateButton.pin
            .height(55)
            .width(275)
            .below(of: conceptionPeriodSelector)
            .hCenter()
            .marginTop(24)
        
        guard !planningView.isHidden else {
            planningView.pin
                .height(0)
                .below(of: calculateButton)
                .horizontally()
                .marginTop(16)
            
            scrollView.updateContentSizeHeight(withBottomPadding: 15)
            
            scrollContentView.pin
                .width(of: scrollView)
                .wrapContent(.vertically)
            
            return
        }
        
        planningView.pin
            .below(of: calculateButton)
            .horizontally()
            .marginTop(16)
            .wrapContent(.vertically)
        
        scrollView.updateContentSizeHeight(withBottomPadding: 15)
        
        scrollContentView.pin
            .width(of: scrollView)
            .wrapContent(.vertically)
    }
}
