//
//  RecommendationsViewController.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class RecommendationsViewController: UIViewController {
    let stepper: Stepper
    private let _view: RecommendationsView
    
    init(presenter: RecommendationsPresenter, _ gender: Gender, _ fromSavedResults: Bool) {
        _view = RecommendationsView(presenter: presenter, gender, fromSavedResults)
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
