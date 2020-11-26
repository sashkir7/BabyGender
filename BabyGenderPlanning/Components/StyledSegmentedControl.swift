//
//  StyledSegmentedControl.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 08/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class StyledSegmentedControl: UISegmentedControl {
    var themeColor = UIColor.selectedSegment
    var textColor = UIColor.barossa.withAlphaComponent(0.9)
    var selectedTextColor = UIColor.white
    var font = UIFont.boldSystemFont(ofSize: 10)
    
    init(items: [Any]?,
         themeColor: UIColor = .selectedSegment,
         textColor: UIColor = UIColor.barossa.withAlphaComponent(0.9),
         selectedTextColor: UIColor = .white,
         font: UIFont = .boldSystemFont(ofSize: 10)) {
        super.init(items: items)
        
        self.themeColor = themeColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.font = font
        
        styleComponents()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        styleComponents()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        styleComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StyledSegmentedControl {
    private func styleComponents() {
        selectedSegmentIndex = 0
        backgroundColor = .appWhite

        layer.borderColor = themeColor.cgColor

        if #available(iOS 13, *) {
            layer.borderWidth = 1
            selectedSegmentTintColor = themeColor
        } else {
            tintColor = themeColor
        }
        
        setTitleTextAttributes([.font: font, .foregroundColor: textColor], for: .normal)
        setTitleTextAttributes([.foregroundColor: selectedTextColor], for: .selected)
    }
}
