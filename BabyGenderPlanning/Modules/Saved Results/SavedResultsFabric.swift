//
//  SavedResultsFabric.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

final class SavedResultsFabric {
    class func assembledScreen() -> SavedResultsViewController {
        let interactor = SavedResultsInteractor()
        let presenter = SavedResultsPresenter(interactor)
        let viewController = SavedResultsViewController(presenter)

        return viewController
    }
}
