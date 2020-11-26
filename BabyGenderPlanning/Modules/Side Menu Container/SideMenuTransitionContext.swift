//
//  SideMenuTransitionContext.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class SideMenuTransitionContext: NSObject, UIViewControllerContextTransitioning {
    var isAnimated = true
    var targetTransform: CGAffineTransform = .identity

    let containerView: UIView
    let presentationStyle: UIModalPresentationStyle

    private var viewControllers = [UITransitionContextViewControllerKey: UIViewController]()

    var isInteractive = false

    var transitionWasCancelled: Bool {
        // Our non-interactive transition can't be cancelled
        return false
    }

    var completion: ((Bool) -> Void)?

    init(with fromViewController: UIViewController, toViewController: UIViewController) {
        guard let superView = fromViewController.view.superview else {
            fatalError("fromViewController's view should have a parent view")
        }
        presentationStyle = .custom
        containerView = superView
        viewControllers = [
            .from: fromViewController,
            .to: toViewController
        ]

        super.init()
    }

    func completeTransition(_ didComplete: Bool) {
        completion?(didComplete)
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case .from:
            return viewControllers[.from]?.view
        case .to:
            return viewControllers[.to]?.view
        default:
            return nil
        }
    }

    func initialFrame(for vc: UIViewController) -> CGRect {
        return containerView.frame
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        return containerView.frame
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func pauseInteractiveTransition() {}
}
