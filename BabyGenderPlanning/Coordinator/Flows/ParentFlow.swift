//
//  ParentFlow.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 16/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class ParentFlow: Flow {
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
        case .parents:
            return navigateToParents()
            
        case .genderPrediction,
             .planning,
             .savedResults,
             .aboutApp,
             .premium:
            return endFlowAndNavigateTo(step)
            
        case .support:
            return navigateToSupport()
            
        case let .showContainer(for: view):
            return navigateToContainer(of: view)
        
        case let .updateParent(parent):
            return navigateToParent(parent)
            
        case let .deleteParent(onDelete):
            return showDeleteParentAlert(onDelete: onDelete)
            
        case let .backParent(onBack):
            return showBackParentAlert(onBack: onBack)

        case .pop:
            return popViewController()
            
        case let .dismissAndPass(data):
            return dismissAndPass(data: data)
            
        case .dismiss:
            return dismissPresented()
            
        default:
            return .none
        }
    }
}

extension ParentFlow {
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
    
    private func navigateToParents() -> FlowContributors {
        guard !isTopViewController(ParentsListViewController.self, at: navigationController) else { return .none }
        let vc = ParentsListFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: false)

        guard let containerStepper = self.stepper else {
            return flowContributor(vc: vc, stepper: vc.stepper)
        }
        let stepper = CompositeStepper(steppers: [vc.stepper, containerStepper])
        
        return flowContributor(vc: vc, stepper: stepper)
    }
    
    private func navigateToContainer(of view: ReusableView) -> FlowContributors {
        let vc = ContainerFabric.assembledScreen(with: view)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }
        
    private func navigateToParent(_ parent: ParentInfo?) -> FlowContributors {
        guard !isTopViewController(ParentViewController.self, at: navigationController) else { return .none }
        let vc = ParentFabric.assembledScreen(parentInfo: parent)
        navigationController.pushViewController(vc, animated: true)

        return flowContributor(vc: vc, stepper: vc.stepper)
    }

    private func showDeleteParentAlert(onDelete: @escaping ((UIAlertAction) -> Void)) -> FlowContributors {
        let alert = UIAlertController.deleteAlert(
            title: Localized.alert_delete_title(),
            message: Localized.alert_delete_message(),
            onDelete: onDelete
        )

        navigationController.present(alert, animated: true)
        return .none
    }
    
    private func showBackParentAlert(onBack: @escaping ((UIAlertAction) -> Void)) -> FlowContributors {
        let alert = UIAlertController.confirmAlert(
            title: Localized.alert_exit_confirmation(),
            message: Localized.alert_agree_exit(),
            onMove: onBack)
        
        navigationController.present(alert, animated: true)
        return .none
    }
    
    private func popViewController() -> FlowContributors {
        navigationController.popViewController(animated: true)
        return .none
    }
    
    private func dismissAndPass(data: ReceivableType) -> FlowContributors {
        let vc = navigationController.children.first(where: { $0 is ParentViewController })
        
        guard let receiverVc = vc as? ParentViewController else {
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

    private func navigateToSupport() -> FlowContributors {
        guard let url = URL(string: "mailto:\(Constants.supportEmail)") else { return .none }
        UIApplication.shared.open(url, options: [:])
        return .none
    }
}
