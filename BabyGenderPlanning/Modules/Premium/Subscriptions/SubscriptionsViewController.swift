//
//  SubscriptionsViewController.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class SubscriptionsViewController: UIViewController {
    private let _view: SubscriptionsView
    private(set) var stepper: Stepper
    
    init(_ presenter: SubscriptionsPresenter) {
        _view = SubscriptionsView(presenter)
        self.stepper = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
}
