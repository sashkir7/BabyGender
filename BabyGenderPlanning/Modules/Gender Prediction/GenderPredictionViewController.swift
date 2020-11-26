//
//  GenderPredictionViewController.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

final class GenderPredictionViewController: UIViewController {
    var receiver: Receiver
    
    private let _view: GenderPredictionView
    private(set) var stepper: Stepper
    
    init(_ presenter: GenderPredictionPresenter) {
        _view = GenderPredictionView(presenter)
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
}

// MARK: - Backward passable implementation

extension GenderPredictionViewController: BackwardPassable {
    func receive(_ data: ReceivableType) {
        switch data {
        case let .parent(parent):
            passParent(parent)
        case let .bloodGroup(bloodGroup, gender):
            passBloodGroup(bloodGroup, for: gender)
        }
    }
    
    func passParent(_ parent: ParentInfo) {
        guard let receiver = receiver as? GenderPredictionReceiver else { return }
        receiver.receiveParent(parent)
    }
    
    func passBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender) {
        guard let receiver = receiver as? GenderPredictionReceiver else { return }
        receiver.receiveBloodGroup(bloodGroup, for: gender)
    }
    
    func clearData() {
        guard let receiver = receiver as? GenderPredictionReceiver else { return }
        
        receiver.clearData()
    }
}
