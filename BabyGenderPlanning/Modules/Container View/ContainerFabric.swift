//
//  ContainerFabric.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 28.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class ContainerFabric {
    class func assembledScreen(with view: ReusableView) -> ContainerViewController {
        let presenter = ContainerPresenter()
        let viewController = ContainerViewController(presenter, insertableView: view.insertable)

        return viewController
    }
}
