//
//  RecommendationsView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout

final class RecommendationsView: UIView {
    private let presenter: RecommendationsPresenterProtocol
    
    private let fromSavedResults: Bool
    
    // MARK: - UI elements
    
    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.page_title_recommendations(), isBackButton: true)
    }()
    
    private lazy var styledTextView = StyledTextView(text: "")
    
    private lazy var newPlanningButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.newReckoning_button_title(), for: .normal)
        
        return button
    }()
    
    // MARK: - Lifecycle

    init(presenter: RecommendationsPresenterProtocol, _ gender: Gender, _ fromSavedResults: Bool) {
        self.presenter = presenter
        self.fromSavedResults = fromSavedResults
        super.init(frame: .zero)

        styledTextView.text = gender == .male ?
            Localized.recommendations_boy() :
            Localized.recommendations_girl()
        
        backgroundColor = .appWhite

        setupBindings()
        setupSubviews()
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

extension RecommendationsView {
    private func setupBindings() {
        let input = RecommendationsPresenter.Input(
            didTapBackTrigger: headerView.menuButtonClicked,
            didTapNewPlanning: newPlanningButton.rx.tap.asObservable()
        )
        
        presenter.buildInput(input)
    }
}

// MARK: - Layout

extension RecommendationsView {
    private func setupSubviews() {
        addSubviews(headerView, styledTextView)
        
        if !fromSavedResults {
            addSubviews(newPlanningButton)
        }
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        styledTextView.pin
            .below(of: headerView)
            .horizontally(16)
            .bottom(107)
        
        if !fromSavedResults {
            newPlanningButton.pin
                .height(55)
                .width(275)
                .below(of: styledTextView)
                .hCenter()
                .marginTop(16)
        }
    }
}
