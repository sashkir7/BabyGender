//
//  SubscriptionsFabric.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class SubscriptionsFabric {
    class func assembledScreen() -> SubscriptionsViewController {
            let interactor = SubscriptionsInteractor()
            let presenter = SubscriptionsPresenter(interactor)
            let viewController = SubscriptionsViewController(presenter)
            
            return viewController
    }
}
