//
//  GenderPlanningFabric.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class GenderPlanningFabric {
    class func assembledScreen(fromPredictionScreen: Bool = false) -> GenderPlanningViewController {
        let interactor = GenderPlanningInteractor(fromPredictionScreen: fromPredictionScreen)
        let presenter = GenderPlanningPresenter(interactor)
        let viewController = GenderPlanningViewController(presenter)

        return viewController
    }
}
