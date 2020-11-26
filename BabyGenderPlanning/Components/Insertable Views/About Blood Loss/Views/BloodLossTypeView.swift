//
//  BloodLossTypeView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class BloodLossTypeView: UIView {
    
    // MARK: - UI Elements
    
    private lazy var bloodImage: UIImageView = {
        return UIImageView(image: Image.bloodLossSingle())
    }()
    
    private(set) lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.numberOfLines = 0

        return label
    }()
    
    init(text: String) {
        super.init(frame: .zero)
        
        typeLabel.text = text
        
        setupSubviews()
        configureFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
}

// MARK: - Layout

extension BloodLossTypeView {
    private func setupSubviews() {
        addSubviews(typeLabel, bloodImage)
    }

    private func configureFrames() {
        bloodImage.pin
            .height(11)
            .width(8)
            .vCenter()
            .left()
        
        typeLabel.pin
            .top()
            .after(of: bloodImage)
            .right()
            .sizeToFit(.width)
            .marginLeft(10)
    }
}
