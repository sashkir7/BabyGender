//
//  ContainerView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 22.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

final class ContainerView: UIView {
    private let presenter: ContainerPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    var insertableView: InsertableView
    
    // MARK: - Lifecycle

    init(_ presenter: ContainerPresenterProtocol, insertableView: InsertableView) {
        self.presenter = presenter
        self.insertableView = insertableView
        super.init(frame: .zero)
        
        backgroundColor = .dropdownShadow
        isOpaque = false

        setupSubviews()
        setupBindings()
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

extension ContainerView {
    private func setupBindings() {
        let input = ContainerPresenter.Input(
            newStep: insertableView.newStepObservable,
            dismiss: insertableView.dismissObservable
        )
        
        presenter.buildInput(with: input)
    }
}

// MARK: - Layout

extension ContainerView {
    private func setupSubviews() {
        addSubview(insertableView)
    }
    
    private func configureSubviews() {
        insertableView.configureLayout()
    }
}
