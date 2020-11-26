//
//  FeatureImageView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 12.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

enum PremiumFeature {
    case planning
    case savedResults
    case parentList
    case calender
}

class FeatureImageView: UIImageView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let type: PremiumFeature
    
    // MARK: - Lifecycle
    
    init(type: PremiumFeature) {
        self.type = type
        
        super.init(frame: .zero)
        
        switch type {
        case .planning:
            imageView.image = Image.menuBaby()
        case .savedResults:
            imageView.image = Image.menuCheckmark()
        case .parentList:
            imageView.image = Image.menuParents()
        default:
            break
        }
        
        setupSubviews()
        applyShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width / 2
        
        applyGradient(colors: .pink,
                      startPoint: .init(x: 0.5, y: 0),
                      endPoint: .init(x: 0.5, y: 1))
        
        configureSubviews()
    }
}

    // MARK: - Layout

extension FeatureImageView {
    private func setupSubviews() {
        addSubview(imageView)
    }
    
    private func configureSubviews() {
        switch type {
        case .planning:
            imageView.pin
                .width(20)
                .height(18)
                .center()
        case .savedResults:
            imageView.pin
                .width(16)
                .height(11)
                .center()
        case .parentList:
            imageView.pin
                .width(24)
                .height(20)
                .center()
        default:
            break
        }
    }
}

extension FeatureImageView {
    private func applyShadow(_ shadowRadius: CGFloat = 4, _ shadowOpacity: Float = 1.0, _ shadowOffset: CGSize = CGSize(width: 0, height: 4)) {
        backgroundColor = .appWhite
        
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = false
        layer.shadowColor = UIColor.dropdownShadow.cgColor
        
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
    }
}
