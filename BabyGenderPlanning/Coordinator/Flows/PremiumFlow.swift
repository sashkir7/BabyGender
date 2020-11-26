//
//  PremiumFlow.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class PremiumFlow: Flow {
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
             .aboutApp:
            return endFlowAndNavigateTo(step)
            
        case let .premium(fromMenu):
            return navigateToAboutPremium(fromMenu: fromMenu)
            
        case .subscriptions:
            return navigateToSubscriptions()
            
        case .support:
            return navigateToSupport()
        
        case .pop:
            return popViewController(animated: true)

        case let .showWarningAlert(title, message):
            return showWarningAlert(title: title, message: message)

        case .trial:
            return navigateToTrial()
            
        default:
            return .none
        }
    }
}

// MARK: - Routing Methods

extension PremiumFlow {
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
    
    private func navigateToAboutPremium(fromMenu: Bool = true) -> FlowContributors {
        guard !isTopViewController(AboutPremiumViewController.self, at: navigationController) else { return .none }
        let vc = AboutPremiumFabric.assembledScreen(fromMenu: fromMenu)
        navigationController.pushViewController(vc, animated: false)
        
        guard let containerStepper = self.stepper else {
            return flowContributor(vc: vc, stepper: vc.stepper)
        }
        let stepper = CompositeStepper(steppers: [vc.stepper, containerStepper])
        
        return flowContributor(vc: vc, stepper: stepper)
    }
    
    private func navigateToSubscriptions() -> FlowContributors {
        guard !isTopViewController(SubscriptionsViewController.self, at: navigationController) else { return .none }
        let vc = SubscriptionsFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: true)
        
        guard let containerStepper = self.stepper else {
            return flowContributor(vc: vc, stepper: vc.stepper)
        }
        let stepper = CompositeStepper(steppers: [vc.stepper, containerStepper])
        
        return flowContributor(vc: vc, stepper: stepper)
    }

    private func navigateToSupport() -> FlowContributors {
        guard let url = URL(string: "mailto:\(Constants.supportEmail)") else { return .none }
        UIApplication.shared.open(url, options: [:])
        return .none
    }
    
    private func popViewController(animated: Bool) -> FlowContributors {
        navigationController.popViewController(animated: animated)
        return .none
    }

    private func showWarningAlert(title: String?, message: String?) -> FlowContributors {
        let alert = UIAlertController.warningAlert(
            title: title,
            message: message
        )

        container.present(alert, animated: true)
        return .none
    }

    private func navigateToTrial() -> FlowContributors {
        guard !isTopViewController(TrialPeriodViewController.self, at: navigationController) else { return .none }

        let vc = TrialPeriodFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: true)

        guard let containerStepper = self.stepper else {
            return flowContributor(vc: vc, stepper: vc.stepper)
        }
        let stepper = CompositeStepper(steppers: [vc.stepper, containerStepper])

        return flowContributor(vc: vc, stepper: stepper)
    }
}
