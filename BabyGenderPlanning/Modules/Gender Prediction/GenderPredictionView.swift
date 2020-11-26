//
//  GenderPredictionView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PinLayout

final class GenderPredictionView: UIView {
    private let presenter: GenderPredictionPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.page_title_genderPrediction())
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubviews(scrollContentView)

        return scrollView
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.addSubviews(segmentedControl, disclaimerContainer,  aboutMethodButton, parentsInputView)
        view.addSubviews(estimatedDateView, checkOnBornChildrensView, calculateButton, predictionsView)

        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentItems = getCalculateMethodTitles()
        return StyledSegmentedControl(items: segmentItems)
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
    
    private lazy var aboutMethodButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.mulberry, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.setTitle(Localized.aboutMethod(), for: .normal)
        return button
    }()
    
    private lazy var parentsInputView: ParentsInputView = {
        let view = ParentsInputView()
        return view
    }()

    private lazy var estimatedDateView: EstimatedConceptionDateView = {
        return EstimatedConceptionDateView(frame: .zero)
    }()

    private lazy var checkOnBornChildrensView: CheckOnBornChildrensView = {
        let view = CheckOnBornChildrensView()
        return view
    }()

    private lazy var calculateButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.calculate_button_title(), for: .normal)

        return button
    }()

    private lazy var predictionsView: PredictionView = {
        let view = PredictionView(frame: .zero)
        view.isHidden = true
        
        return view
    }()

    // MARK: - Lifecycle

    init(_ presenter: GenderPredictionPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)

        backgroundColor = .appWhite

        setupSubviews()
        updateLayout()
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

extension GenderPredictionView {
    private func setupBindings() {
        let needToUpdate = Observable
            .merge(predictionsView.needToUpdate.asObservable(),
                   checkOnBornChildrensView.needToUpdate.asObservable(),
                   parentsInputView.needToUpdate.asObservable())
        
        headerView.menuButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)
            
        let input = GenderPredictionPresenter.Input(
            needToUpdate: needToUpdate,
            
            fatherBirthdayDate: parentsInputView.fatherBirthdayDate,
            fatherBloodGroup: parentsInputView.fatherBloodGroup,
            fatherBloodLossDate: parentsInputView.fatherBloodLossDate,
            motherBirthdayDate: parentsInputView.motherBirthdayDate,
            motherBloodGroup: parentsInputView.motherBloodGroup,
            motherBloodLossDate: parentsInputView.motherBloodLossDate,
            
            fatherDropDownAction: parentsInputView.fatherDropDownAction,
            motherDropDownAction: parentsInputView.motherDropDownAction,
            
            conceptionDate: estimatedDateView.conceptionDate,
            
            didScrollView: scrollView.rx.didScroll.asObservable(),
            didSwitchCalculationMethod: segmentedControl.rx.value.asObservable(),
            didTapAboutMethod: aboutMethodButton.rx.tap.asObservable(),
            didSwitchCheckOnBornChildren: checkOnBornChildrensView.didSwitchCheckOnBornChildren,
            didChangeBornChildData: checkOnBornChildrensView.bornChildData,
            didTapOnAboutFemaleBloodLoss: parentsInputView.showFemaleAboutBloodLoss,
            didTapOnAboutMaleBloodLoss: parentsInputView.showMaleAboutBloodLoss,
            didTapOnCalculateButton: calculateButton.rx.tap.asObservable(),
            didTapOnFemaleBloodGroup: parentsInputView.showFemaleBloodGroupPicker,
            didTapOnMaleBloodGroup: parentsInputView.showMaleBloodGroupPicker,
            didTapOnPlanButton: predictionsView.didTapOnPlanButton
        )
        
        let output = presenter.buildOutput(with: input)
        
        disposeBag.insert(
            output.clearAllData.drive(onNext: { [unowned self] in self.clearAllData() }),
            output.selectedMethod.drive(parentsInputView.selectedMethod),
            output.conceptionPrediction.drive(onNext: (checkOnBornChildrensView.updatePrediction)),
            output.shouldHideEstimatedDateView.drive(estimatedDateView.rx.isHidden),
            output.loadedMother.drive(parentsInputView.loadedMother),
            output.loadedFather.drive(parentsInputView.loadedFather),
            output.fatherBloodGroup.drive(parentsInputView.setFatherBloodGroup),
            output.motherBloodGroup.drive(parentsInputView.setMotherBloodGroup),
            output.predictionResult.drive(predictionsView.rx.prediction),
            output.shouldScrollToBottom.drive(scrollView.rx.scrollToBottom),
            output.message.drive(rx.toastMessage),
            output.shouldUpdateLayout.drive(onNext: { [unowned self] in self.updateLayout() })
        )
    }
    
    private func clearAllData() {
        Observable.just(0).asDriverOnErrorJustComplete().drive(segmentedControl.rx.value).dispose()
        
        parentsInputView.selectedMethod.accept(.freymanDobroting)
        parentsInputView.loadedFather.accept(nil)
        parentsInputView.loadedMother.accept(nil)
        
        Observable.just(nil).asDriverOnErrorJustComplete().drive(estimatedDateView.dateTextField.rx.date).dispose()
        
        checkOnBornChildrensView.showBornChildrens.accept(false)
        checkOnBornChildrensView.babyInputView.clearData.accept(())
        
        Observable.just(nil).asDriverOnErrorJustComplete().drive(predictionsView.rx.prediction).dispose()
        
        scrollView.contentOffset.y = 0
    }
}

// MARK: - Private Methods

extension GenderPredictionView {
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
        
        parentsInputView.pin
            .below(of: aboutMethodButton)
            .horizontally()
            .marginTop(16)
            .wrapContent(.vertically)
        
        estimatedDateView.pin
            .height(56)
            .below(of: parentsInputView)
            .horizontally()
            .marginTop(25)
        
        checkOnBornChildrensView.pin
            .below(of: visible([parentsInputView, estimatedDateView]))
            .horizontally()
            .marginTop(25)
            .wrapContent(.vertically)
        
        calculateButton.pin
            .height(55)
            .width(275)
            .below(of: checkOnBornChildrensView)
            .hCenter()
            .marginTop(24)
        
        guard !predictionsView.isHidden else {
            predictionsView.pin
                .height(0)
                .below(of: calculateButton)
                .horizontally()
                .marginTop(16)
            
            scrollView.updateContentSizeHeight()
            
            scrollContentView.pin
                .width(of: scrollView)
                .wrapContent(.vertically)
            
            return
        }
        
        predictionsView.pin
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
