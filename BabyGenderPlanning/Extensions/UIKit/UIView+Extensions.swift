//
//  UIView + Extensions.swift
//
//  Created by Nikita Velichkin on 25/01/2020.
//  Copyright © 2020 Nikita Velichkin. All rights reserved.
//

import UIKit
import PinLayout

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview(_:))
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach(addSubview(_:))
    }
    
    func removeSubviews(_ views: UIView...) {
        views.forEach { $0.removeFromSuperview() }
    }
    
    func removeSubviews(_ views: [UIView]) {
        views.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Custom toast view

extension UIView {
    func showToast(with message: String, font: UIFont = UIFont.titleFont) {
        let view = UIView()
        let label = UILabel()
        
        view.backgroundColor = .toastColor
        view.layer.cornerRadius = 20
        view.alpha = 0
        
        label.backgroundColor = .clear
        label.font = font
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message
        
        view.addSubview(label)
        
        let completion: ((Bool) -> Void) = { _ in
            view.removeFromSuperview()
        }
        
        let animation: () -> Void = {
            view.alpha = 0
        }
        
        UIWindow.keyWindow?.addSubview(view)
        
        view.pin
            .horizontally(15)
            .bottom(bounds.height / 5)
        
        label.pin
            .top()
            .minHeight(20)
            .horizontally(15)
            .sizeToFit(.width)
        
        view.pin
            .wrapContent(.vertically, padding: Padding.inset(top: 10, bottom: 10))
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                view.alpha = 1
            },
            completion: { _ in
                UIView.animate(withDuration: 1, delay: 3, animations: animation, completion: completion)
            })
    }
}
