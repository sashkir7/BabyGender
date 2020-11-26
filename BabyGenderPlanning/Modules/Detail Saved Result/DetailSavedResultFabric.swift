//
//  DetailSavedResultFabric.swift
//  BabyGenderPlanning
//
//  Created by Alx Krw on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class DetailSavedResultFabric {
    class func assembledScreen(withCalculationInfo info: CalculationInfo) -> DetailSavedResultViewController {
        let interactor = DetailSavedResultInteractor(withCalculationInfo: info)
        let presenter = DetailSavedResultPresenter(interactor)
        let viewController = DetailSavedResultViewController(presenter)

        return viewController
    }
}
