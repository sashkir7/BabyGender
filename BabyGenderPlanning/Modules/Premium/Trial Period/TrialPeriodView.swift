//
//  TrialPeriodView.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 08.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import PinLayout

final class TrialPeriodView: UIView {
    private let presenter: TrialPeriodPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements

    private lazy var headerView: HeaderTitleView = {
        let view = HeaderTitleView(title: Localized.premium_title_trial_period(), isBackButton: true)
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
        view.addSubviews(imageView, aboutTrialLabel, trialButton, subscribeButton)

        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Image.trialFutureMother()

        return imageView
    }()

    private lazy var aboutTrialLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.numberOfLines = 0
        label.textAlignment = .center

        if let oneMonthPriceSubscription = PremiumService.shared.oneMonthPrice.value {
            label.text = Localized.premium_about_trial_period_first() + ": " + oneMonthPriceSubscription + ".\n" +
                Localized.premium_about_trial_period_last()
        } else {
            label.text = Localized.premium_about_trial_period_first() + ".\n" + Localized.premium_about_trial_period_last()
        }

        return label
    }()

    private lazy var trialButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.premium_three_days_free(), for: .normal)

        return button
    }()

    private lazy var subscribeButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.premium_subscribe(), for: .normal)

        return button
    }()

    private lazy var loadingView = LoadingView()
    
    // MARK: - Lifecycle
    
    init(_ presenter: TrialPeriodPresenterProtocol) {
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

extension TrialPeriodView {
    private func setupBindings() {
        let input = TrialPeriodPresenter.Input(
            backTrigger: headerView.menuButton.rx.tap.asObservable(),
            didTapTrialPeriod: trialButton.rx.tap.asObservable(),
            didTapSubscribe: subscribeButton.rx.tap.asObservable()
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
            })
        )
    }
}

// MARK: - Private Methods

extension TrialPeriodView {
    
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

        imageView.pin
            .top(30)
            .size(190)
            .hCenter()

        aboutTrialLabel.pin
            .below(of: imageView)
            .marginTop(8)
            .horizontally(25)
            .sizeToFit(.width)

        if PremiumService.shared.isUsedTrialPeriod.value {
            subscribeButton.pin
                .below(of: aboutTrialLabel)
                .marginTop(20)
                .height(55)
                .width(275)
                .hCenter()
        } else {
            trialButton.pin
                .below(of: aboutTrialLabel)
                .marginTop(20)
                .height(55)
                .width(275)
                .hCenter()

            subscribeButton.pin
                .below(of: trialButton)
                .marginTop(19)
                .height(55)
                .width(275)
                .hCenter()
        }
        
        scrollView.updateContentSizeHeight(withBottomPadding: 15)

        scrollContentView.pin
            .width(of: scrollView)
            .wrapContent(.vertically)
    }
}
