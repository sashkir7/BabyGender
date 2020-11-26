//
//  GradientColors.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

enum GradientColors {
    case pink
    case purple
    case buttonPurple

    var value: [CGColor] {
        switch self {
            
        case .pink:
            return [UIColor(254, 246, 244),
                    UIColor(251, 225, 230)]
                .map { $0.cgColor }

        case .purple:
            return [UIColor(170, 75, 151),
                    UIColor(254, 178, 170)]
                .map { $0.cgColor }

        case .buttonPurple:
            return [UIColor(170, 75, 151),
                    UIColor(254, 178, 170)]
                .map { $0.cgColor }
            
        }
    }

    func withOpacity(_ opacity: CGFloat) -> [CGColor] {
        return self.value
            .map(UIColor.init)
            .map { $0.withAlphaComponent(opacity) }
            .map { $0.cgColor }
    }
}
