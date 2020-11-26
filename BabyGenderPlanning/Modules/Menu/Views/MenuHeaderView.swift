//
//  MenuHeaderView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class MenuHeaderView: UIView {

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.titleFont.bold
        label.textColor = .barossa
        label.text = Localized.sideMenu_title()

        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Image.union(), for: .normal)
        button.imageView?.alpha = 0.7
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)

        return button
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .appWhite

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

extension MenuHeaderView {
    private func setupSubviews() {
        addSubviews(titleLabel, closeButton)
    }

    private func configureSubviews() {
        titleLabel.pin
            .vertically()
            .left()
            .before(of: closeButton)
            .marginRight(18)
            .sizeToFit()
        
        closeButton.pin
            .size(14)
            .vCenter()
            .right()
    }
}

extension MenuHeaderView {
    @objc private func handleClose() {
        Menu.toggle()
    }
}
