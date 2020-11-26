//
//  CalculationsFlow.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class CalculationsFlow: Flow {
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
             .aboutApp,
             .parents,
             .premium,
             .newPlanning:
            return endFlowAndNavigateTo(step)
        
        case .support:
                return navigateToSupport()
            
        case .savedResults:
            return navigateToSavedResults()
            
        case let .recommendations(gender):
            return navigateToRecommendations(gender)
            
        case let .deleteCalculation(onDelete):
            return showDeleteCalculationAlert(onDelete)
            
        case let .showAllDates(calculationInfo):
            return navigateToShowAllDates(calculationInfo)
            
        case .pop:
            return popViewController(animated: true)
            
        default:
            return .none
        }
    }
}

// MARK: - Routing Methods

extension CalculationsFlow {
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
    
    private func navigateToSupport() -> FlowContributors {
        guard let url = URL(string: "mailto:\(Constants.supportEmail)") else { return .none }
        UIApplication.shared.open(url, options: [:])
        return .none
    }
    
    private func navigateToSavedResults() -> FlowContributors {
        guard !isTopViewController(SavedResultsViewController.self, at: navigationController) else { return .none }
        let vc = SavedResultsFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: false)
        
        guard let containerStepper = self.stepper else {
            return flowContributor(vc: vc, stepper: vc.stepper)
        }
        let stepper = CompositeStepper(steppers: [vc.stepper, containerStepper])
        
        return flowContributor(vc: vc, stepper: stepper)
    }
    
    private func navigateToRecommendations(_ gender: Gender) -> FlowContributors {
        guard !isTopViewController(RecommendationsViewController.self, at: navigationController) else {
            return .none
        }
        let vc = RecommendationsFabric.assembledScreen(for: gender, fromSavedResults: true)
        navigationController.pushViewController(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }
    
    private func showDeleteCalculationAlert(_ onDelete: @escaping ((UIAlertAction) -> Void)) -> FlowContributors {
        let alert = UIAlertController.deleteAlert(
            title: Localized.alert_delete_title(),
            message: Localized.alert_delete_message(),
            onDelete: onDelete
        )

        navigationController.present(alert, animated: true)
        return .none
    }
    
    private func navigateToShowAllDates(_ calculationInfo: CalculationInfo) -> FlowContributors {
        let vc = DetailSavedResultFabric.assembledScreen(withCalculationInfo: calculationInfo)
        navigationController.pushViewController(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }
    
    private func popViewController(animated: Bool) -> FlowContributors {
        navigationController.popViewController(animated: animated)
        return .none
    }
}
