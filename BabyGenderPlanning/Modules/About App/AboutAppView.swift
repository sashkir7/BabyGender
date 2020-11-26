//
//  AboutAppView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AboutAppView: UIView {
    private let presenter: AboutAppPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI elements
    
    private lazy var headerView: HeaderTitleView = {
        return AcceptPolicyService.isAcceptPolicy ?
            HeaderTitleView(title: Localized.sideMenu_about()) :
            HeaderTitleView(title: Localized.sideMenu_about(), isBackButton: true)
    }()
    
    private lazy var styledTextView = StyledTextView(text: Localized.aboutApp())

    private lazy var acceptButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.button_accept(), for: .normal)

        return button
    }()

    // MARK: - Lifecycle

    init(_ presenter: AboutAppPresenterProtocol) {
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

extension AboutAppView {
    private func setupBindings() {
        let input = AboutAppPresenter.Input(
            acceptButtonTap: acceptButton.rx.tap.asObservable(),
            backButtonTap: headerView.menuButtonClicked
        )
        let output = presenter.buildOutput(with: input)

        disposeBag.insert(
            output.message.drive(rx.toastMessage)
        )
    }
}

// MARK: - Layout

extension AboutAppView {
    private func setupSubviews() {
        addSubviews(headerView, styledTextView, acceptButton)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()

        guard !AcceptPolicyService.isAcceptPolicy else {
            styledTextView.pin
            .below(of: headerView)
            .horizontally(16)
            .bottom(44)

            return
        }

        acceptButton.pin
            .height(55)
            .width(275)
            .hCenter()
            .bottom(15)

        styledTextView.pin
            .horizontally(16)
            .below(of: headerView)
            .above(of: acceptButton)
            .marginBottom(16)
    }
}
