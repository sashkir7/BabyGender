//
//  AboutFlow.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class AboutFlow: Flow {
    var root: Presentable {
        return container
    }

    let container: SideMenuController
    let stepper: Stepper?
    let navigationController: UINavigationController
    
    init(with container: SideMenuController, nc: UINavigationController) {
        self.container = container
        self.stepper = container.stepper
        self.navigationController = nc
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? RouteStep else { return .none }

        switch step {
            
        case .genderPrediction,
             .planning,
             .savedResults,
             .parents,
             .premium:
            return endFlowAndNavigateTo(step)
            
        case .aboutApp:
            return navigateToAboutApp()
            
        case .support:
            return navigateToSupport()
            
        default:
            return .none
        }
    }
}

// MARK: - Routing Methods

extension AboutFlow {
    private func endFlowAndNavigateTo(_ step: Step) -> FlowContributors {
        guard let routeStep = step as? RouteStep else { return .none }
        switch routeStep {
        case .genderPrediction:
            return .end(forwardToParentFlowWithStep: step)
        default:
            navigationController.popToRootViewController(animated: false)
            return .end(forwardToParentFlowWithStep: step)
        }
    }
    
    private func navigateToAboutApp() -> FlowContributors {
        guard !isTopViewController(AboutAppViewController.self, at: navigationController) else { return .none }
        let vc = AboutAppFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: false)
        
        guard let containerStepper = self.stepper else {
            return .none
        }
        
        return flowContributor(vc: vc, stepper: containerStepper)
    }

    private func navigateToSupport() -> FlowContributors {
        guard let url = URL(string: "mailto:\(Constants.supportEmail)") else { return .none }
        UIApplication.shared.open(url, options: [:])
        return .none
    }
}
