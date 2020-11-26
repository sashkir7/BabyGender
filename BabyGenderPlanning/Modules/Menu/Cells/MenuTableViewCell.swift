//
//  MenuTableViewCell.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell, ClassIdentifiable {

    // MARK: - Properties

    private var isPremiumFeature = false

    // MARK: - UI Elements

    private lazy var iconImageView: UIImageView = {
        return UIImageView()
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa

        return label
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: .init(top: 2, left: 0, bottom: 2, right: 0))

        configureSubviews()

        guard isPremiumFeature else { return }
        contentView.applyGradient(cgColors: GradientColors.purple.withOpacity(0.15),
                                  startPoint: .init(x: 0, y: 0.5),
                                  endPoint: .init(x: 1, y: 0.5))
    }

    internal func configure(row: MenuRow) {
        iconImageView.image = row.icon
        titleLabel.text = row.title
        self.isPremiumFeature = row.isPremiumFeature

        contentView.removeGradientIfExists()
    }
}

// MARK: - Layout

extension MenuTableViewCell {
    private func setupSubviews() {
        contentView.addSubviews(iconImageView, titleLabel)
    }

    private func configureSubviews() {
        iconImageView.pin
            .left(15)
            .vCenter()
            .sizeToFit()
        
        titleLabel.pin
            .left(49)
            .right()
            .vCenter()
            .sizeToFit()
    }
}
