//
//  ParentSectionHeaderView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 16/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ParentSectionHeaderView: UITableViewHeaderFooterView, ClassIdentifiable {

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.generalTextFont.bold
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)

        return label
    }()

    // MARK: - Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let backgroundView = UIView()
        self.backgroundView = backgroundView
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }

    internal func configure(with gender: Gender) {
        titleLabel.text = gender == .male ? Localized.father_section_title() : Localized.mother_section_title()
    }
}

// MARK: - Layout

extension ParentSectionHeaderView {
    private func setupSubviews() {
        addSubviews(titleLabel)
    }

    private func configureSubviews() {
        titleLabel.pin
            .center()
            .sizeToFit()
    }
}
