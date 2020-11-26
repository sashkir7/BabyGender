//
//  MainFlow.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

final class MainFlow: Flow {
    var root: Presentable {
        return container
    }

    private lazy var container: SideMenuController = {
        let menu = MenuFabric.assembledScreen()
        
        return SideMenuController(
            contentViewController: UIViewController(),
            menuViewController: menu,
            menuWidth: 281
        )
    }()
    
    lazy var navigationController: UINavigationController = {
        let nc = UINavigationController()
        nc.setNavigationBarHidden(true, animated: false)
        return nc
    }()

    private var menuStepper: Stepper {
        guard let stepper = container.stepper else { fatalError("Set up menu first!") }
        return stepper
    }

    private var menuFlowContributor: FlowContributor {
        return .contribute(
            withNextPresentable: container.menuViewController,
            withNextStepper: menuStepper,
            allowStepWhenNotPresented: true
        )
    }
    
    // swiftlint:disable cyclomatic_complexity
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? RouteStep else { return .none }

        switch step {
        case .start:
            return startNavigation()
            
        case .genderPrediction:
            return navigateToGenderPrediction()
            
        case let .showContainer(for: view):
            return navigateToContainer(of: view)

        case let .premium(fromMenu):
            return navigateToPremium(fromMenu: fromMenu)

        case let .planning(father, mother):
            return navigateToPlanning(father: father, mother: mother)
            
        case .newPlanning:
            return navigateToPlanning(father: nil, mother: nil)

        case .parents:
            return navigateToParents(step: step)
        
        case .updateParent:
            return navigateToParents(step: step)

        case .savedResults:
            return navigateToSavedResults()

        case .support:
            return navigateToSupport()

        case .aboutApp:
            return navigateToAboutApp()
            
        case let .okAlert(title, message):
            return showOkAlert(title: title, message: message)
            
        case let .dismissAndPass(data):
            return dismissAndPass(data: data)

        case .dismiss:
            return dismissPresented()
            
        case let .popTo(vc):
            return popToViewController(vc)
        default:
            return .none
        }
    }
    
    // swiftlint:enable cyclomatic_complexity
}

// MARK: - Routing Methods

extension MainFlow {
    private func startNavigation() -> FlowContributors {
        guard !isTopViewController(UINavigationController.self, at: container) else { return .none }
        let vc = GenderPredictionFabric.assembledScreen()
        navigationController.pushViewController(vc, animated: false)

        container.setRootViewController(navigationController)

        let compositeStepper = CompositeStepper(steppers: [menuStepper, vc.stepper])
        return flowContributor(vc: vc, stepper: compositeStepper)
    }
    
    private func navigateToGenderPrediction() -> FlowContributors {
        guard !isTopViewController(GenderPredictionViewController.self, at: navigationController) else { return .none }

        if let vc = navigationController.viewControllers.first as? BackwardPassable {
            vc.clearData()
        }

        navigationController.popToRootViewController(animated: false)

        return .none
    }

    private func navigateToContainer(of view: ReusableView) -> FlowContributors {
        let vc = ContainerFabric.assembledScreen(with: view)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
        
        return flowContributor(vc: vc, stepper: vc.stepper)
    }

    private func navigateToPremium(fromMenu: Bool = true) -> FlowContributors {
        let flow = PremiumFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: .premium(fromMenu: fromMenu))

        return .one(flowContributor: flowContributor)
    }

    private func navigateToPlanning(father: ParentInfo?, mother: ParentInfo?) -> FlowContributors {
        let flow = PlanningFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: .planning(father: father, mother: mother))
        
        return .one(flowContributor: flowContributor)
    }

    private func navigateToParents(step: RouteStep) -> FlowContributors {
        let flow = ParentFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: step)

        return .one(flowContributor: flowContributor)
    }

    private func navigateToSavedResults() -> FlowContributors {
        let flow = CalculationsFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: .savedResults)

        return .one(flowContributor: flowContributor)
    }

    private func navigateToAboutApp() -> FlowContributors {
        let flow = AboutFlow(with: container, nc: navigationController)
        let flowContributor = nextFlowContributor(flow: flow, step: .aboutApp)

        return .one(flowContributor: flowContributor)
    }

    private func navigateToSupport() -> FlowContributors {
        guard let url = URL(string: "mailto:\(Constants.supportEmail)") else { return .none }
        UIApplication.shared.open(url, options: [:])
        return .none
    }
    
    private func showOkAlert(title: String?, message: String?) -> FlowContributors {
        let alert = UIAlertController.warningAlert(
            title: title,
            message: message
        )
        
        container.present(alert, animated: true)
        
        return .none
    }
    
    private func dismissAndPass(data: ReceivableType) -> FlowContributors {
        let vc = navigationController.children.first(where: { $0 is BackwardPassable })
        
        guard let receiverVc = vc as? BackwardPassable else {
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
    
    private func popToViewController(_ vc: UIViewController.Type) -> FlowContributors {
        guard let nextVc = navigationController.children.first(where: { $0.isKind(of: vc) }) else {
            return .none
        }
        
        navigationController.popToViewController(nextVc, animated: false)
        return .none
    }
}
