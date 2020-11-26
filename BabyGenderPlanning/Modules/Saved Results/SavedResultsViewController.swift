//
//  SavedResultsViewController.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class SavedResultsViewController: UIViewController {
    private let _view: SavedResultsView
    private(set) var stepper: Stepper
    
    init(_ presenter: SavedResultsPresenter) {
        _view = SavedResultsView(presenter)
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
