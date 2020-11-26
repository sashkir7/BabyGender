//
//  LoadingView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 11.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    private let indicator = UIActivityIndicatorView(style: .whiteLarge)
    
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        setupSubviews()
        
        indicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frame = superview?.bounds ?? .zero
        configureSubviews()
    }
}

extension UIView {
    func showHUD(_ hud: LoadingView, with text: String) {
        hud.alpha = 1
        hud.text = text
        addSubview(hud)
    }
    
    func removeHUD(_ hud: LoadingView, withDelay seconds: TimeInterval = 0, completion: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5,
                       delay: seconds,
                       options: .curveEaseInOut,
                       animations: {
                        hud.alpha = 0
        },
                       completion: { _ in
                        hud.removeFromSuperview()
                        completion?()
        })
    }
}

// MARK: - Layout

private extension LoadingView {
    func setupSubviews() {
        addSubviews(indicator, label)
    }
    
    func configureSubviews() {
        indicator.pin
            .center()
        
        label.pin
            .below(of: indicator)
            .horizontally(16)
            .sizeToFit(.width)
            .marginTop(8)
    }
}
