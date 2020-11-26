//
//  NSAttributedString+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension NSAttributedString {
    convenience init(_ string: String, font: UIFont, textColor: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]
        self.init(string: string, attributes: attributes)
    }
}
