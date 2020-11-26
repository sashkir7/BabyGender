//
//  MenuFabric.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class MenuFabric {
    class func assembledScreen() -> MenuViewController {
        let interactor = MenuInteractor()
        let presenter = MenuPresenter(interactor)
        let viewController = MenuViewController(presenter)

        return viewController
    }
}
