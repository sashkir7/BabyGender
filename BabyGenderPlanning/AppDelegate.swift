//
//  AppDelegate.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 20/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxFlow
import IQKeyboardManagerSwift
import Purchases

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let coordinator = FlowCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Purchases.debugLogsEnabled = false
        Purchases.configure(withAPIKey: Constants.apiKey)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15

        window = UIWindow()
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()

        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        ReachabilityService.shared.setupReachibility()
        startNavigation()
                
        return true
    }

    private func startNavigation() {
        let startFlow = StartFlow()
        let stepper = OneStepper(withSingleStep: RouteStep.start)

        coordinator.coordinate(flow: startFlow, with: stepper)
    }
}
