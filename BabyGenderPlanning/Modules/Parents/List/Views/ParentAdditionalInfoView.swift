//
//  ParentAdditionalInfoView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ParentAdditionalInfoView: UIView {

    // MARK: - UI Elements
    
    private lazy var bloodLossDateLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.text = Localized.bloodLoss_date_title()

        return label
    }()

    private lazy var bloodLossValueLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)

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

    func configure(bloodLossDate: Date) {
        bloodLossValueLabel.text = bloodLossDate.format(dateFormat: .ddMMYYYY)
    }
}

// MARK: - Layout

extension ParentAdditionalInfoView {
    private func setupSubviews() {
        addSubviews(bloodLossDateLabel, bloodLossValueLabel)
    }
    
    private func configureSubviews() {
        bloodLossDateLabel.pin
            .top()
            .left(14)
            .before(of: bloodLossValueLabel)
            .sizeToFit(.width)
            .marginRight(10)

        bloodLossValueLabel.pin
            .width(85)
            .height(18)
            .vCenter(to: bloodLossDateLabel.edge.vCenter)
            .right(14)
    }
}
