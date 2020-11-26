//
//  ResultParentsInfoView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ResultParentsInfoView: UIView {
    var motherNameString: String? {
        didSet { femaleDateLabel.text = motherNameString }
    }
    
    var fatherNameString: String? {
        didSet { maleDateLabel.text = fatherNameString }
    }
    
    // MARK: - UI elements
    
    private lazy var maleImage: UIImageView = {
        return UIImageView(image: Image.maleSymbolSmall())
    }()
    
    private lazy var femaleImage: UIImageView = {
        return UIImageView(image: Image.femaleSymbolSmall())
    }()
    
    private lazy var maleDateLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var femaleDateLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
}

// MARK: - Layout

extension ResultParentsInfoView {
    private func setupSubviews() {
        addSubviews(maleImage, femaleImage, maleDateLabel, femaleDateLabel)
    }
    
    private func configureSubviews() {
        femaleImage.pin
            .height(42)
            .width(27)
            .top()
            .left()
        
        femaleDateLabel.pin
            .after(of: femaleImage)
            .vCenter(to: femaleImage.edge.vCenter)
            .right()
            .marginLeft(20)
            .sizeToFit(.width)
        
        maleImage.pin
            .size(33)
            .below(of: femaleImage)
            .left()
            .marginTop(24)
        
        maleDateLabel.pin
            .after(of: maleImage)
            .vCenter(to: maleImage.edge.vCenter)
            .right()
            .marginLeft(14)
            .sizeToFit(.width)
    }
}
