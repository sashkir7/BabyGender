//
//  RecommendationsFabric.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

final class RecommendationsFabric {
    class func assembledScreen(for gender: Gender, fromSavedResults: Bool = false) -> RecommendationsViewController {
        let presenter = RecommendationsPresenter()
        let viewController = RecommendationsViewController(presenter: presenter, gender, fromSavedResults)

        return viewController
    }
}
