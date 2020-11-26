//
//  DetailSavedResultViewController.swift
//  BabyGenderPlanning
//
//  Created by Alx Krw on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class DetailSavedResultViewController: UIViewController {
    private let _view: DetailSavedResultView
    private(set) var stepper: Stepper
    
    init(_ presenter: DetailSavedResultPresenter) {
        _view = DetailSavedResultView(presenter)
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
