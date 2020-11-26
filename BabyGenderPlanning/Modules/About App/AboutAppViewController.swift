//
//  AboutAppViewController.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class AboutAppViewController: UIViewController {
    private let _view: AboutAppView
    private(set) var stepper: Stepper
    
    init(_ presenter: AboutAppPresenter) {
        _view = AboutAppView(presenter)
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
