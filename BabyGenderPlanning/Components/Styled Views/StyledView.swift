//
//  StyledView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class StyledView: UIView {

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyShadow()
    }

    init(shadowRadius: CGFloat, shadowOpacity: Float, shadowOffset: CGSize) {
        super.init(frame: .zero)
        applyShadow(shadowRadius, shadowOpacity, shadowOffset)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StyledView {
    private func applyShadow(_ shadowRadius: CGFloat = 10, _ shadowOpacity: Float = 1.0, _ shadowOffset: CGSize = CGSize(width: 0, height: 6)) {
        backgroundColor = .appWhite

        layer.cornerRadius = Constants.styledViewCornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.viewShadow.cgColor

        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
    }
}
