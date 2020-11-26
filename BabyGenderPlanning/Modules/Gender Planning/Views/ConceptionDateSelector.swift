//
//  ConceptionPeriodSelector.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout
import RxSwift
import RxCocoa

final class ConceptionPeriodSelector: UIView {
    
    // MARK: - Observables
    
    var conceptionPeriodInMonth: Observable<Int> {
        return periodSelector.rx.value
            .map { period in
                return period == 3 ? 6 : period + 1
            }
    }
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = Localized.chooseConceptionDatePeriod()
        label.font = .titleFont
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)
        
        return label
    }()
    
    private lazy var periodSelector: StyledSegmentedControl = {
        let items = [Localized.oneMonth(), Localized.twoMonth(), Localized.threeMonth(), Localized.sixMonth()]
        let themeColor = UIColor.selectedSegmentPink
        let selectedTextColor = UIColor.barossa
        let font = UIFont.generalTextFont
        
        let control = StyledSegmentedControl(items: items, themeColor: themeColor, selectedTextColor: selectedTextColor, font: font)
        
        control.layer.borderWidth = 0
        
        return control
    }()
    
    init() {
        super.init(frame: .zero)
        
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

private extension ConceptionPeriodSelector {
    func setupSubviews() {
        addSubviews(titleLabel, periodSelector)
    }
    
    func configureSubviews() {
        titleLabel.pin
            .top()
            .horizontally()
            .sizeToFit(.width)
        
        periodSelector.pin
            .height(40)
            .below(of: titleLabel)
            .horizontally()
            .marginTop(10)
    }
}
