//
//  AboutAppFabric.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

final class AboutAppFabric {
    class func assembledScreen() -> AboutAppViewController {
        let presenter = AboutAppPresenter()
        let viewController = AboutAppViewController(presenter)

        return viewController
    }
}
