//
//  GenderPredictionFabric.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class GenderPredictionFabric {
    class func assembledScreen() -> GenderPredictionViewController {
        let interactor = GenderPredictionInteractor()
        let presenter = GenderPredictionPresenter(interactor)
        let viewController = GenderPredictionViewController(presenter)

        return viewController
    }
}
