//
//  SideMenuController.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow

protocol SideMenuControllerType {
    var isMenuRevealed: Bool { get }
    var stepper: Stepper? { get }
    var topViewController: UIViewController? { get }

    func toggleMenu(animated: Bool, completion: ((Bool) -> Void)?)
    func setRootViewController(_ vc: UIViewController)
    func pushViewController(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?)
    func popViewController(animated: Bool, completion: (() -> Void)?)
}

class SideMenuController: UIViewController {

    private(set) var isMenuRevealed: Bool = false

    var stepper: Stepper? {
        return (menuViewController as? MenuViewController)?.stepper
    }

    var topViewController: UIViewController? {
        return childrens.top ?? contentViewController
    }

    // MARK: - Controllers

    private(set) var menuViewController: UIViewController {
        didSet {
            guard menuViewController !== oldValue,
                isViewLoaded
                else { return }

            load(menuViewController, on: menuContainerView)
            unload(oldValue)
        }
    }

    private(set) var contentViewController: UIViewController {
        didSet {
            guard contentViewController !== oldValue,
                isViewLoaded,
                !children.contains(contentViewController)
                else { return }

            load(contentViewController, on: contentContainerView)
            contentContainerView.sendSubviewToBack(contentViewController.view)
            unload(oldValue)

            setNeedsStatusBarAppearanceUpdate()
        }
    }

    private var menuWidth: CGFloat

    private var childrens = Stack<UIViewController>()

    private let menuContainerView = UIView()
    private let contentContainerView = UIView()

    private weak var contentContainerOverlay: UIView?

    private weak var panGestureRecognizer: UIPanGestureRecognizer?

    private var isValidatePanningBegan = false
    private var panningBeganPointX: CGFloat = 0

    // MARK: - Lifecycle

    init(contentViewController: UIViewController, menuViewController: UIViewController, menuWidth: CGFloat) {
        
        self.menuWidth = menuWidth
        self.contentViewController = contentViewController
        self.menuViewController = menuViewController

        super.init(nibName: nil, bundle: nil)
    }

    init() {
        self.menuWidth = 0
        self.contentViewController = UIViewController()
        self.menuViewController = UIViewController()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentContainerView.frame = view.bounds
        view.addSubview(contentContainerView)

        menuContainerView.frame = sideMenuFrame(isVisible: false)
        view.addSubview(menuContainerView)

        load(contentViewController, on: contentContainerView)
        load(menuViewController, on: menuContainerView)

        setNeedsStatusBarAppearanceUpdate()

        configureGesturesRecognizer()
    }
}

// MARK: - Content Overlay

extension SideMenuController {
    private func addContentOverlayViewIfNeeded() {
        guard contentContainerOverlay == nil else {
            return
        }

        let overlay = UIView(frame: contentContainerView.bounds)
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        overlay.backgroundColor = .appBlack
        overlay.alpha = 0.2

        let tapToHideGesture = UITapGestureRecognizer()
        tapToHideGesture.addTarget(self, action: #selector(handleTapGesture(_:)))
        overlay.addGestureRecognizer(tapToHideGesture)

        contentContainerView.insertSubview(overlay, aboveSubview: contentViewController.view)
        contentContainerOverlay = overlay
    }
}

// MARK: - Coordination

extension SideMenuController: SideMenuControllerType {

    func toggleMenu(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        isMenuRevealed ?
            hideMenu(animated: animated, completion: completion) :
            revealMenu(animated: animated, completion: completion)
    }

    func setRootViewController(_ vc: UIViewController) {
        childrens = Stack()
        childrens.push(vc)
        contentViewController = vc
    }

    func pushViewController(_ vc: UIViewController,
                            animated: Bool = true,
                            completion: (() -> Void)? = nil) {
        childrens.push(vc)
        setContentViewController(viewController: vc,
                                 animated: animated,
                                 completion: completion)
    }

    func popViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        childrens.pop()
        guard let vc = childrens.top else { return }
        setContentViewController(viewController: vc,
                                 animated: animated,
                                 completion: completion)
    }
}

// MARK: - Private Coordination

extension SideMenuController {

    @objc private func handleTapGesture(_ tap: UITapGestureRecognizer) {
        hideMenu()
    }

    private func revealMenu(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        changeMenuVisibility(reveal: true, animated: animated, completion: completion)
    }

    private func hideMenu(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        changeMenuVisibility(reveal: false, animated: animated, completion: completion)
    }

    private func changeMenuVisibility(reveal: Bool,
                                      animated: Bool = true,
                                      completion: ((Bool) -> Void)? = nil) {
        menuViewController.beginAppearanceTransition(true, animated: true)

        if reveal {
            addContentOverlayViewIfNeeded()
        }

        UIApplication.shared.beginIgnoringInteractionEvents()

        let animationClosure = {
            self.menuContainerView.frame = self.sideMenuFrame(isVisible: reveal)
            self.contentContainerView.frame = self.contentFrame()
        }

        let animationCompletionClosure: (Bool) -> Void = { finish in
            self.menuViewController.endAppearanceTransition()

            if !reveal {
                self.contentContainerOverlay?.removeFromSuperview()
                self.contentContainerOverlay = nil
            }

            completion?(true)

            UIApplication.shared.endIgnoringInteractionEvents()

            self.isMenuRevealed = reveal
        }

        if animated {
            animateMenu(with: reveal,
                        animations: animationClosure,
                        completion: animationCompletionClosure)
        } else {
            animationClosure()
            animationCompletionClosure(true)
            completion?(true)
        }

    }

    private func animateMenu(with reveal: Bool,
                             animations: @escaping () -> Void,
                             completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: animations,
            completion: completion
        )
    }

    private func setContentViewController(viewController: UIViewController,
                                          animated: Bool = false,
                                          completion: (() -> Void)? = nil) {

        guard contentViewController !== viewController && isViewLoaded else {
            completion?()
            return
        }

        if animated {
            addChild(viewController)

            viewController.view.frame = view.bounds
            viewController.view.translatesAutoresizingMaskIntoConstraints = true
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let animator = SideMenuTransitionAnimator()

            let transitionContext = SideMenuTransitionContext(
                with: contentViewController,
                toViewController: viewController
            )

            transitionContext.isAnimated = true
            transitionContext.isInteractive = false
            transitionContext.completion = { finish in
                self.unload(self.contentViewController)
                self.contentViewController = viewController
                viewController.didMove(toParent: self)

                completion?()
            }

            animator.animateTransition(using: transitionContext)

        } else {
            contentViewController = viewController
            completion?()
        }
    }
}

// MARK: - Frames

extension SideMenuController {
    private func sideMenuFrame(isVisible: Bool, targetSize: CGSize? = nil) -> CGRect {
        var baseFrame = CGRect(origin: view.frame.origin, size: targetSize ?? view.frame.size)

        let offset = isVisible ? 0 : -menuWidth
        baseFrame.origin.x = offset
        baseFrame.size.width = menuWidth

        return CGRect(origin: baseFrame.origin, size: targetSize ?? baseFrame.size)
    }

    private func contentFrame(targetSize: CGSize? = nil) -> CGRect {
        return CGRect(origin: view.frame.origin, size: targetSize ?? view.frame.size)
    }
}

// MARK: - Transition

extension SideMenuController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        hideMenu(animated: false, completion: { _ in
            self.menuContainerView.isHidden = true
            coordinator.animate(alongsideTransition: { _ in
                self.contentContainerView.frame = self.contentFrame(targetSize: size)
            }, completion: { _ in
                self.menuContainerView.isHidden = false
                self.menuContainerView.frame = self.sideMenuFrame(isVisible: self.isMenuRevealed, targetSize: size)
            })
        })

        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - Gesture

extension SideMenuController {
    private func configureGesturesRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(SideMenuController.handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        panGestureRecognizer = panGesture
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var translation = pan.translation(in: pan.view).x

        let viewToAnimate = menuContainerView
        let containerWidth = viewToAnimate.frame.width
        let leftBorder = -containerWidth
        let rightBorder = menuWidth - containerWidth

        switch pan.state {
        case .began:
            panningBeganPointX = viewToAnimate.frame.origin.x
            isValidatePanningBegan = false

        case .changed:
            let resultX = panningBeganPointX + translation
            let notReachLeftBorder = resultX >= leftBorder
            let notReachRightBorder = resultX <= rightBorder

            guard notReachLeftBorder && notReachRightBorder else {
                return
            }

            if !isValidatePanningBegan {
                addContentOverlayViewIfNeeded()
                isValidatePanningBegan = true
            }

            let notReachDesiredBorder = resultX <= rightBorder

            if notReachDesiredBorder {
                viewToAnimate.frame.origin.x = resultX
            } else {
                if !isMenuRevealed {
                    translation -= menuWidth
                }
                viewToAnimate.frame.origin.x = rightBorder + menuWidth
                    * log10(translation / menuWidth + 1) * 0.5
            }

            let movingDistance = menuContainerView.frame.maxX
            let shadowPercent = min(movingDistance / menuWidth, 1)
            contentContainerOverlay?.alpha = 0.2 * shadowPercent

        case .ended, .cancelled, .failed:
            let offset = viewToAnimate.frame.maxX
            let offsetPercent = offset / menuWidth
            let decisionPoint: CGFloat = isMenuRevealed ? 0.85 : 0.15

            changeMenuVisibility(reveal: offsetPercent > decisionPoint)

        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SideMenuController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if touch.view is UISlider {
            return false
        }

        if let scrollView = touch.view as? UIScrollView, scrollView.frame.width > scrollView.contentSize.width {
            return false
        }

        return true
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let velocity = panGestureRecognizer?.velocity(in: view) else {
            return true
        }

        return isValidateHorizontalMovement(for: velocity)
    }

    private func isValidateHorizontalMovement(for velocity: CGPoint) -> Bool {
        guard !isMenuRevealed else { return true }
        guard velocity.x > 0 else { return false }

        return abs(velocity.y / velocity.x) < 0.25
    }
}
