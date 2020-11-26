//
//  ContainerViewController.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 22.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

protocol InsertableView: UIView {
    // MARK: - Layout methods
    func configureLayout()
    
    // MARK: - Navigation observables
    var newStepObservable: Observable<RouteStep> { get }
    var dismissObservable: Observable<Void> { get }
}

final class ContainerViewController: UIViewController {
    private let _view: ContainerView
    private(set) var stepper: Stepper
    
    init(_ presenter: ContainerPresenter, insertableView: InsertableView) {
        _view = ContainerView(presenter, insertableView: insertableView)
        stepper = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
}
