//
//  StartFlow.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class StartFlow: Flow {
    var root: Presentable {
        return UIViewController()
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? RouteStep else { return .none }

        switch step {

        case .start:
            return AcceptPolicyService.isAcceptPolicy ?
                navigateToMainFlow() :
                showAboutAppScreen()

        default:
            return .none
        }
    }
}

// MARK: - Routing Methods

extension StartFlow {
    private func navigateToMainFlow() -> FlowContributors {
        let flow = MainFlow()
        let stepper = OneStepper(withSingleStep: RouteStep.start)
        let flowContributor = FlowContributor.contribute(withNextPresentable: flow, withNextStepper: stepper)

        Flows.whenReady(flow1: flow) { container in
            UIWindow.keyWindow?.rootViewController = container
        }

        return .one(flowContributor: flowContributor)
    }

    private func showAboutAppScreen() -> FlowContributors {
        let vc = AboutAppFabric.assembledScreen()

        Flows.whenReady(flow1: self) { _ in
            UIWindow.keyWindow?.rootViewController = vc
        }

        return flowContributor(vc: vc, stepper: vc.stepper)
    }
}
