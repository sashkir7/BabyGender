//
//  PlanningResultView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 30.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PinLayout

final class PlanningResultView: UIView {
    var calculationInfo: CalculationInfo? {
        didSet { updateCalculationInfo(calculationInfo) }
    }
    
    // MARK: - Observables
    
    var didTapTipsButton: Observable<Void> {
        return recommendationsButton.rx.tap.asObservable()
    }
    
    // MARK: - UI Elements
    
    private lazy var styledView = StyledView()
    
    private lazy var genderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.2
        imageView.image = Image.aGirl()
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .barossa
        label.font = .generalTextFont
        
        return label
    }()
    
    private lazy var favorableDatesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var recommendationsButton: GradientButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.recommendations_button_title(), for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect = .zero) {
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
    
    private func updateCalculationInfo(_ info: CalculationInfo?) {
        guard let info = info else {
            isHidden = true
            return
        }
        
        isHidden = false
        
        let titleText = info.gender == .male ?
            Localized.favorableConceptionDaysForBoy():
            Localized.favorableConceptionDaysForGirl()
        
        let image = info.gender == .male ?
            Image.aBoy():
            Image.aGirl()
        
        let favorableDatesText = info.conceptionDatesStrings
        
        titleLabel.text = titleText
        genderImage.image = image
        favorableDatesLabel.attributedText = favorableDatesText
        
        updateLayout()
    }
}

// MARK: - Layout

extension PlanningResultView {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        styledView.addSubviews(titleLabel, favorableDatesLabel, genderImage)
        addSubviews(styledView, recommendationsButton)
    }

    private func configureSubviews() {
        styledView.pin
            .minHeight(124)
            .top()
            .horizontally()
        
        titleLabel.pin
            .top()
            .horizontally(5)
            .sizeToFit(.width)
        
        favorableDatesLabel.pin
            .below(of: titleLabel)
            .horizontally(14)
            .sizeToFit(.width)
            .marginTop(12)
        
        genderImage.pin
            .top(10)
            .hCenter()
            .sizeToFit()
        
        styledView.pin
            .wrapContent(.vertically, padding: Padding.inset(top: 10, bottom: 10))
        
        recommendationsButton.pin
            .height(55)
            .width(275)
            .below(of: styledView)
            .hCenter()
            .marginTop(24)
    }
}

// MARK: - Reactive

extension Reactive where Base: PlanningResultView {
    var planning: Binder<CalculationInfo?> {
        return Binder(base) { view, result in
            view.calculationInfo = result
        }
    }
}
