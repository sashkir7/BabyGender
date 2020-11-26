//
//  UIScrollView+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 15/03/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIScrollView {
    func updateContentSizeHeight(withBottomPadding bottom: CGFloat = 0) {
        guard let lastSubview = lastSubview else { return }

        let newContentSize = lastSubview.frame.maxY
        contentSize.height = newContentSize + bottom
    }

    private var lastSubview: UIView? {
        return subviews.first?.subviews
            .max(by: { $0.frame.maxY < $1.frame.maxY })
    }
}
