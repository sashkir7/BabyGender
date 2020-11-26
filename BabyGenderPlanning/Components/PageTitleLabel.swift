//
//  PageTitleLabel.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class PageTitleLabel: UILabel {
    init(titleText: String = "") {
        super.init(frame: .zero)

        font = UIFont.titleFont.bold
        textColor = .barossa
        textAlignment = .center
        text = titleText
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
