//
//  PlanningFlow.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class PlanningFlow: Flow {
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
        case let .planning(father, mother):
            return navigateToPlanning(father: father, mother: mother)
            
        case .genderPrediction,
             .parents,
             .savedResults,
             .aboutApp,
             .premium,
             .newPlanning:
            return endFlowAndNavigateTo(step)
            
        case .support:
            return navigateToSupport()
            
        case let .recommendations(gender):
            return navigateToRecommendations(gender)
            
        case let .showContainer(for: view):
            return navigateToContainer(of: view)
        
        case .updateParent:
            return navigateToParents(step: step)
            
        case .pop:
            return popViewController(animated: true)
            
        case let .dismissAndPass(data):
            return dismissAndPass(data: data)
            
        case .dismiss:
            return dismissPresented()
            
        default:
            return .none
        }
    }
}

extension PlanningFlow {
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
    
    private func navigateToPlanning(father: ParentInfo?, mother: ParentInfo?) -> FlowContributors {
        guard !isTopViewController(GenderPlanningViewController.self, at: navigationController) else { return .none }
        let vc = GenderPlanningFabric.assembledScreen(fromPredictionScreen: father != nil)
        navigationController.pushViewController(vc, animated: false)
        
        if let father = father, let mother = mother {
            vc.receive(.parent(father))
            vc.receive(.parent(mother))
        }
        
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
        let vc = RecommendationsFabric.assembledScreen(for: gender)
        navigationController.pushViewController(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }
    
    private func navigateToContainer(of view: ReusableView) -> FlowContributors {
        let vc = ContainerFabric.assembledScreen(with: view)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }
    
    private func navigateToParents(step: RouteStep) -> FlowContributors {
        let flow = ParentFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: step)

        return .one(flowContributor: flowContributor)
    }
    
    private func popViewController(animated: Bool) -> FlowContributors {
        navigationController.popViewController(animated: animated)
        return .none
    }
    
    private func dismissAndPass(data: ReceivableType) -> FlowContributors {
        let vc = navigationController.children.first(where: { $0 is GenderPlanningViewController })
        
        guard let receiverVc = vc as? GenderPlanningViewController else {
            navigationController.dismiss(animated: true)
            return .none
        }
        
        receiverVc.receive(data)
        
        navigationController.dismiss(animated: true)
        return .none
    }
    
    private func dismissPresented() -> FlowContributors {
        navigationController.dismiss(animated: true)
        return .none
    }
}
