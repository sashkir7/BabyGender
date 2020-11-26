//
//  TrialPeriodViewController.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 08.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class TrialPeriodViewController: UIViewController {
    private let _view: TrialPeriodView
    private(set) var stepper: Stepper
    
    init(_ presenter: TrialPeriodPresenter) {
        _view = TrialPeriodView(presenter)
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
