//
//  InsertableTextView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift

final class InsertableTextView: UIView, InsertableView {
    var newStepObservable: Observable<RouteStep> = .empty()
    var dismissObservable: Observable<Void> = .empty()
    
    // MARK: - UI Elements
    
    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.sideMenu_about(), isBackButton: true)
    }()
    
    private lazy var styledTextView = StyledTextView(text: "")
    
    // MARK: - Lifecycle

    init(text: String, title: String) {
        super.init(frame: .zero)
        headerView.title = title
        styledTextView.text = text
        dismissObservable = headerView.menuButtonClicked
        
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

// MARK: - Layout

extension InsertableTextView {
    func configureLayout() {
        pin.vertically().horizontally()
    }
    
    private func setupSubviews() {
        addSubviews(headerView, styledTextView)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        styledTextView.pin
            .below(of: headerView)
            .horizontally(16)
            .bottom(44)
    }
}
