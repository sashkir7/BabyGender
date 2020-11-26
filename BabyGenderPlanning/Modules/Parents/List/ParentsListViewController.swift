//
//  ParentsListViewController.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class ParentsListViewController: UIViewController {
    private let _view: ParentsListView
    private(set) var stepper: Stepper
    
    init(_ presenter: ParentsListPresenter) {
        _view = ParentsListView(presenter)
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
