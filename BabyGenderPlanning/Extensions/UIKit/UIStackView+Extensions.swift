//
//  UIStackView+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 08/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
