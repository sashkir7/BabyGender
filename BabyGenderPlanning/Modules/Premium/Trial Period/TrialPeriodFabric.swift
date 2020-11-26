//
//  TrialPeriodFabric.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 08.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class TrialPeriodFabric {
    class func assembledScreen() -> TrialPeriodViewController {
        let interactor = TrialPeriodInteractor()
        let presenter = TrialPeriodPresenter(interactor)
        let viewController = TrialPeriodViewController(presenter)

        return viewController
    }
}
