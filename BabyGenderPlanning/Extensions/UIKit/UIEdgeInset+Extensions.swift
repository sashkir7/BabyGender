//
//  UIEdgeInset+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 20.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

typealias Padding = UIEdgeInsets

extension Padding {
    
    static func inset(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> Padding {
        return Padding(top: top, left: left, bottom: bottom, right: right)
    }
    
    static func inset(top: Int = 0, bottom: Int = 0, left: Int = 0, right: Int = 0) -> Padding {
        return Padding(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right))
    }
    
}
