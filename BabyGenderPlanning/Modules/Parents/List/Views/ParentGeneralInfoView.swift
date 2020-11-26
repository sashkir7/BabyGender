//
//  ParentGeneralInfoView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ParentGeneralInfoView: UIView {

    // MARK: - UI Elements

    private lazy var birthdayDateLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.numberOfLines = 0

        return label
    }()

    private lazy var birthdayDateValueLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)
        label.numberOfLines = 0

        return label
    }()

    private lazy var bloodGroupLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.text = Localized.bloodGroup()
        label.textAlignment = .left
        label.numberOfLines = 0

        return label
    }()

    private lazy var bloodGroupValueLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)
        label.numberOfLines = 0

        return label
    }()

    // MARK: - Lifecycle

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

    func configure(parent: ParentInfo) {
        birthdayDateLabel.text = parent.gender == .male ? Localized.maleBirthdayDate() : Localized.femaleBirthdayDate()

        birthdayDateValueLabel.text = parent.birthdayDate.format(dateFormat: .ddMMYYYY)
        bloodGroupValueLabel.text = parent.bloodGroup?.stringFormatted ?? "-"
    }
}

// MARK: - Layout

extension ParentGeneralInfoView {
    private func setupSubviews() {
        addSubviews(birthdayDateLabel, birthdayDateValueLabel, bloodGroupLabel, bloodGroupValueLabel)
    }

    private func configureSubviews() {
        birthdayDateLabel.pin
            .top()
            .left(14)
            .before(of: birthdayDateValueLabel)
            .sizeToFit(.width)
            .marginRight(10)
        
        birthdayDateValueLabel.pin
            .width(85)
            .top()
            .right(14)
            .sizeToFit(.width)
        
        bloodGroupLabel.pin
            .below(of: birthdayDateValueLabel)
            .bottom()
            .left(14)
            .before(of: bloodGroupValueLabel)
            .sizeToFit(.width)
            .marginTop(20)
            .marginRight(10)
        
        bloodGroupValueLabel.pin
            .width(of: birthdayDateValueLabel)
            .vCenter(to: bloodGroupLabel.edge.vCenter)
            .right(to: birthdayDateValueLabel.edge.right)
            .sizeToFit(.width)
    }
}
