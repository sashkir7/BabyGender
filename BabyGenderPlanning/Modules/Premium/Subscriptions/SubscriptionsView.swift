//
//  SubscriptionsView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SubscriptionsView: UIView {
    private let presenter: SubscriptionsPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        let view = HeaderTitleView(title: Localized.sideMenu_premium(), isBackButton: true)
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubviews(scrollContentView)

        return scrollView
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.addSubviews(descriptionLabel, oneMonthButton, threeMonthsButton, sixMonthsButton)
        view.addSubviews(oneYearButton, threeMonthsSavingLabel, sixMonthsSavingLabel, oneYearSavingLabel)

        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.text = Localized.subscription_description()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var oneMonthButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.subscription_oneMonth(), for: .normal)
        
        return button
    }()
    
    private lazy var threeMonthsButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.subscription_threeMonths(), for: .normal)
        
        return button
    }()
    
    private lazy var sixMonthsButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.subscription_sixMonths(), for: .normal)
        
        return button
    }()
    
    private lazy var oneYearButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.subscription_oneYear(), for: .normal)
        
        return button
    }()
    
    private lazy var threeMonthsSavingLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.text = Localized.subscription_threeMonths_saving()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var sixMonthsSavingLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.text = Localized.subscription_sixMonths_saving()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var oneYearSavingLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.text = Localized.subscription_oneYear_saving()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var loadingView = LoadingView()
    
    // MARK: - Init
    
    init(_ presenter: SubscriptionsPresenterProtocol) {
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

extension SubscriptionsView {
    private func setupBindings() {
        let input = SubscriptionsPresenter.Input(
            backButtonTap: headerView.menuButtonClicked,
            oneMonthTap: oneMonthButton.rx.tap.asObservable(),
            threeMonthsTap: threeMonthsButton.rx.tap.asObservable(),
            sixMonthsTap: sixMonthsButton.rx.tap.asObservable(),
            oneYearTap: oneYearButton.rx.tap.asObservable()
        )
        
        let output = presenter.buildOutput(with: input)
        
        disposeBag.insert(
            output.showLoader
                .drive(onNext: { [unowned self] text in
                    self.loadingView.text = text
                    self.showHUD(self.loadingView, with: text)
                }),
            
            output.hideLoader
                .drive(onNext: { [unowned self] text in
                    self.loadingView.text = text
                    self.removeHUD(self.loadingView, withDelay: 2.0)
                }),

            output.oneMonthButtonTitle.drive(oneMonthButton.rx.title()),
            output.threeMonthButtonTitle.drive(threeMonthsButton.rx.title()),
            output.sixMonthButtonTitle.drive(sixMonthsButton.rx.title()),
            output.oneYearButtonTitle.drive(oneYearButton.rx.title()),

            output.threeMonthSaleTitle.drive(threeMonthsSavingLabel.rx.text),
            output.sixMonthSaleTitle.drive(sixMonthsSavingLabel.rx.text),
            output.oneYearSaleTitle.drive(oneYearSavingLabel.rx.text)
        )
    }
}

// MARK: - Private Methods

extension SubscriptionsView {
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
        
        descriptionLabel.pin
            .below(of: headerView)
            .horizontally(20)
            .sizeToFit(.width)
        
        [oneMonthButton, threeMonthsButton, sixMonthsButton, oneYearButton].forEach { button in
            button.pin.height(55).width(275).hCenter()
        }
        
        oneMonthButton.pin
            .below(of: descriptionLabel)
            .marginTop(20)
        
        threeMonthsButton.pin
            .below(of: oneMonthButton)
            .marginTop(48)
        
        sixMonthsButton.pin
            .below(of: threeMonthsButton)
            .marginTop(48)
        
        oneYearButton.pin
            .below(of: sixMonthsButton)
            .marginTop(48)
        
        threeMonthsSavingLabel.pin
            .below(of: threeMonthsButton)
            .width(of: threeMonthsButton)
            .hCenter()
            .sizeToFit(.width)
            .marginTop(8)
        
        sixMonthsSavingLabel.pin
            .below(of: sixMonthsButton)
            .width(of: sixMonthsButton)
            .hCenter()
            .sizeToFit(.width)
            .marginTop(8)
        
        oneYearSavingLabel.pin
            .below(of: oneYearButton)
            .width(of: oneYearButton)
            .hCenter()
            .sizeToFit(.width)
            .marginTop(8)
        
        scrollView.updateContentSizeHeight(withBottomPadding: 15)
        
        scrollContentView.pin
            .width(of: scrollView)
            .wrapContent(.vertically)
    }
}
