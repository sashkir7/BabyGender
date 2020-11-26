//
//  ParentsListFabric.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class ParentsListFabric {
    class func assembledScreen() -> ParentsListViewController {
        let interactor = ParentsListInteractor()
        let presenter = ParentsListPresenter(interactor)
        let viewController = ParentsListViewController(presenter)

        return viewController
    }
}
