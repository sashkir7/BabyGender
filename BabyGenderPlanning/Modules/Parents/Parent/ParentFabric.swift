//
//  ParentFabric.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

final class ParentFabric {
    class func assembledScreen(parentInfo: ParentInfo?) -> ParentViewController {
            let interactor = ParentInteractor(withParentInfo: parentInfo)
            let presenter = ParentPresenter(interactor)
            let viewController = ParentViewController(presenter)
            
            return viewController
    }
}
