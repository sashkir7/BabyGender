//
//  RxFlow+Menu.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 16/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import UIKit

extension Flow {
    func isTopViewController(_ type: UIViewController.Type, at container: SideMenuController) -> Bool {
        return container.topViewController?.isKind(of: type.self) ?? false
    }
    
    func isTopViewController(_ type: UIViewController.Type, at container: UINavigationController) -> Bool {
        return container.topViewController?.isKind(of: type.self) ?? false
    }

    func flowContributor(vc: UIViewController, stepper: Stepper) -> FlowContributors {
        let flowContributor = FlowContributor.contribute(withNextPresentable: vc, withNextStepper: stepper)
        return .one(flowContributor: flowContributor)
    }

    func nextFlowContributor(flow: Flow, step: RouteStep) -> FlowContributor {
        return FlowContributor.contribute(
            withNextPresentable: flow,
            withNextStepper: OneStepper(step: step)
        )
    }
}

extension OneStepper {
    convenience init(step: RouteStep) {
        self.init(withSingleStep: step)
    }
}
