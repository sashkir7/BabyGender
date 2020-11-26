//
//  ParentViewController.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class ParentViewController: UIViewController {
    var receiver: Receiver
    
    private let _view: ParentView
    private(set) var stepper: Stepper
    
    init(_ presenter: ParentPresenter) {
        receiver = presenter
        _view = ParentView(presenter)
        self.stepper = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    func receive(_ data: ReceivableType) {
        switch data {
        case let .bloodGroup(bloodGroup, gender):
            passBloodGroup(bloodGroup, for: gender)
        default:
            return
        }
    }
}

// MARK: - Backward passable implementation

extension ParentViewController: BackwardPassable {
    func passBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender) {
        guard let receiver = receiver as? ParentPresenterReceiver else { return }
        receiver.receiveBloodGroup(bloodGroup)
    }
}
