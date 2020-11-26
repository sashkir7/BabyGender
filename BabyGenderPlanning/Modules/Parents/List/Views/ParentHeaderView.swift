//
//  ParentHeaderView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ParentHeaderView: UIView {

    // MARK: - UI Elements

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center

        return label
    }()

    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.addSubviews(editButton, deleteButton)

        return view
    }()

    private(set) lazy var editButton = ImageButton(image: Image.editUnfilled())
    
    private(set) lazy var deleteButton = ImageButton(image: Image.delete())

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

    internal func configure(parent: ParentInfo) {
        titleLabel.text = parent.name
    }
}

// MARK: - Layout

extension ParentHeaderView {
    private func setupSubviews() {
        addSubviews(titleLabel, buttonsView)
    }

    private func configureSubviews() {
        titleLabel.pin
            .vCenter()
            .horizontally(14)
            .sizeToFit(.width)
        
        buttonsView.pin
            .height(38)
            .width(70)
            .vCenter()
            .right(6)
        
        deleteButton.pin
            .width(14)
            .height(18)
            .vCenter()
            .right(10)
        
        editButton.pin
            .size(16)
            .vCenter()
            .before(of: deleteButton)
            .marginRight(20)
    }
}
