//
//  AboutPremiumCollectionViewCell.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum PremiumExampleCard {
    case genderPlanning
    case savingResults
    case advantages
}

class AboutPremiumCollectionViewCell: UICollectionViewCell, ClassIdentifiable {

    // MARK: - UI Elements

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhite
        view.layer.cornerRadius = Constants.styledViewCornerRadius
        view.addSubviews(titleLabel, centralImage, descriptionLabel)

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()

    private lazy var centralImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }

    internal func configure(card: PremiumExampleCard) {
        switch card {
        case .genderPlanning:
            centralImage.image = Image.premiumCardOne()
            titleLabel.text = Localized.premium_title_one()
            descriptionLabel.text = Localized.premium_description_one()
            
        case .savingResults:
            centralImage.image = Image.premiumCardTwo()
            titleLabel.text = Localized.premium_title_two()
            descriptionLabel.text = Localized.premium_description_two()
            
        case .advantages:
            centralImage.image = Image.premiumCardThree()
            titleLabel.text = Localized.premium_title_three()
            descriptionLabel.text = Localized.premium_description_three()
        }
    }
}

// MARK: - Layout

extension AboutPremiumCollectionViewCell {
    private func setupSubviews() {
        addSubviews(cardView)
    }

    private func configureSubviews() {
        cardView.pin
            .vertically()
            .horizontally()
        
        titleLabel.pin
            .top(20)
            .horizontally(8)
            .sizeToFit(.width)
        
        descriptionLabel.pin
            .bottom(45)
            .horizontally(8)
            .sizeToFit(.width)
        
        centralImage.pin
            .below(of: titleLabel)
            .above(of: descriptionLabel)
            .horizontally(20)
            .marginTop(12)
            .marginBottom(12)
        
    }
}
