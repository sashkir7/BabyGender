//
//  ParentsListFabric.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class AboutPremiumFabric {
    class func assembledScreen(fromMenu: Bool = true) -> AboutPremiumViewController {
        let interactor = AboutPremiumInteractor(fromMenu: fromMenu)
        let presenter = AboutPremiumPresenter(interactor)
        let viewController = AboutPremiumViewController(presenter)

        return viewController
    }
}
