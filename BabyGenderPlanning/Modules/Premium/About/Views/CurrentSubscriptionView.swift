//
//  CurrentSubscriptionView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 12.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CurrentSubscriptionView: UIView {
    
    // MARK: - UI Elements
    
    var date: Date? {
        didSet {
            guard let date = date else {
                isHidden = true
                return
            }
            isHidden = false
            descriptionLabel.text = Localized.valid_until() + " " + date.format(dateFormat: .ddMMYYYY)
        }
    }

    var title: String? {
        didSet {
            guard let title = title else { return }
            titleLabel.text = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Localized.my_premium_title()
        
        return label
    }()
    
    private lazy var featuresContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var planningFeatureImageView = FeatureImageView(type: .planning)
    
    private lazy var saveResultsFeatureImageView = FeatureImageView(type: .savedResults)
    
    private lazy var parentsListFeatureImageView = FeatureImageView(type: .parentList)

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Localized.valid_until()
        
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .appWhite
        layer.cornerRadius = Constants.styledViewCornerRadius

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

extension CurrentSubscriptionView {
    private func setupSubviews() {
        featuresContainer.addSubviews(planningFeatureImageView, saveResultsFeatureImageView, parentsListFeatureImageView)
        addSubviews(titleLabel, featuresContainer, descriptionLabel)
    }

    private func configureSubviews() {
        titleLabel.pin
            .top(18)
            .horizontally(9)
            .sizeToFit(.width)
        
        planningFeatureImageView.pin
            .vertically()
            .left()
            .aspectRatio(1)
        
        saveResultsFeatureImageView.pin
            .vertically()
            .after(of: planningFeatureImageView)
            .marginLeft(18)
            .aspectRatio(1)
        
        parentsListFeatureImageView.pin
            .vertically()
            .after(of: saveResultsFeatureImageView)
            .marginLeft(18)
            .right()
        
        featuresContainer.pin
            .below(of: titleLabel)
            .marginTop(8)
            .height(36)
            .width(144)
            .hCenter()
        
        descriptionLabel.pin
            .below(of: featuresContainer)
            .horizontally(9)
            .marginTop(8)
            .sizeToFit(.width)
            .bottom(12)
    }
}

extension Reactive where Base: CurrentSubscriptionView {
    var date: Binder<Date?> {
        return Binder(base) { view, date in
            view.date = date
        }
    }

    var title: Binder<String?> {
        return Binder(base) { view, title in
            view.title = title
        }
    }
}
