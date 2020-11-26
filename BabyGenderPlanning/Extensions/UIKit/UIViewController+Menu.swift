//
//  UIViewController+Menu.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class Menu {
    private static var sideMenuController: SideMenuController? = {
        return UIWindow.keyWindow?.rootViewController as? SideMenuController
    }()

    static func toggle() {
        guard let sideMenuController = sideMenuController else { return }
        sideMenuController.toggleMenu()
    }
}

extension UIViewController {

    func load(_ viewController: UIViewController?, on view: UIView) {
        guard let viewController = viewController else {
            return
        }

        addChild(viewController)

        viewController.view.frame = view.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(viewController.view)

        viewController.didMove(toParent: self)
    }

    func unload(_ viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()

        DispatchQueue.main.async {
            viewController.removeFromParent()
        }
    }
}
