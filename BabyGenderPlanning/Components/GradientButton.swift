//
//  GradientButton.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

final class GradientButton: UIButton {

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 17
        
        setTitleColor(.white, for: .normal)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        titleLabel?.font = .boldSystemFont(ofSize: 15)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(colors: .buttonPurple,
                      startPoint: .init(x: 0, y: 0.5),
                      endPoint: .init(x: 1, y: 0.5))
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        let title = title?.uppercased()
        super.setTitle(title, for: .normal)
    }
}
