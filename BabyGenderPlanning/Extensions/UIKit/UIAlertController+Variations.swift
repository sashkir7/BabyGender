//
//  UIAlertController+Variations.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 16/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func deleteAlert(title: String?, message: String?, onDelete: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let deleteAction = UIAlertAction(title: Localized.alert_delete(), style: .destructive, handler: onDelete)

        return createAlert(title: title, message: message, actions: [.cancelAction, deleteAction])
    }
    
    static func confirmAlert(title: String?, message: String?, onMove: @escaping((UIAlertAction) -> Void)) -> UIAlertController {
        let confirmAction = UIAlertAction(title: Localized.alert_ok(), style: .destructive, handler: onMove)
        
        return createAlert(title: title, message: message, actions: [.cancelAction, confirmAction])
    }
    
    static func warningAlert(title: String?, message: String?) -> UIAlertController {
        return createAlert(title: title, message: message, actions: [.okAction])
    }

    private static func createAlert(title: String?, message: String?, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alert.addAction(_:))

        return alert
    }
}

extension UIAlertAction {
    static var cancelAction: UIAlertAction {
        return UIAlertAction(title: Localized.alert_cancel(), style: .cancel)
    }
    
    static var okAction: UIAlertAction {
        return UIAlertAction(title: Localized.alert_ok(), style: .cancel)
    }
}
