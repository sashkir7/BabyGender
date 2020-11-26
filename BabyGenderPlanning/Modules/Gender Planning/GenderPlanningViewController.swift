//
//  GenderPlanningViewController.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class GenderPlanningViewController: UIViewController {
    var receiver: Receiver
    
    private let _view: GenderPlanningView
    private(set) var stepper: Stepper
    
    init(_ presenter: GenderPlanningPresenter) {
        _view = GenderPlanningView(presenter)
        self.stepper = presenter
        self.receiver = presenter
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
        case let .parent(parent):
            passParent(parent)
        case let .bloodGroup(bloodGroup, gender):
            passBloodGroup(bloodGroup, for: gender)
        }
    }
}

// MARK: - Backward passable implementation

extension GenderPlanningViewController: BackwardPassable {
    func passParent(_ parent: ParentInfo) {
        guard let receiver = receiver as? GenderPlanningReceiver else { return }
        receiver.receiveParent(parent)
    }
    
    func passBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender) {
        guard let receiver = receiver as? GenderPlanningReceiver else { return }
        receiver.receiveBloodGroup(bloodGroup, for: gender)
    }
}
