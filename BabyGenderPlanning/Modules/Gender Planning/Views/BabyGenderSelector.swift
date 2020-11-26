//
//  BabyGenderSelector.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PinLayout

final class BabyGenderSelector: UIView {
    
    // MARK: - Observables
    
    var genderChanged: Observable<Gender> {
        let girlTaps = girlButton.rx.tap.map { Gender.female }
        let boyTaps = boyButton.rx.tap.map { Gender.male }
        let genderTaps = Observable.merge(girlTaps, boyTaps)
        return genderTaps.startWith(.female).distinctUntilChanged()
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI elements
    
    private lazy var styledView = StyledView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localized.choosePlannedBabyGender()
        label.font = .generalTextFont
        label.textColor = .barossa
        
        return label
    }()
    
    private lazy var girlButton: ImageButton = {
        return ImageButton(image: Image.aGirl())
    }()
    
    private lazy var boyButton: UIButton = {
        return ImageButton(image: Image.aBoy())
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
        
        genderChanged.subscribe(onNext: (invertGender)).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    private func invertGender(to gender: Gender) {
        guard gender == .female else {
            girlButton.alpha = 0.4
            boyButton.alpha = 1
            return
        }
        
        girlButton.alpha = 1
        boyButton.alpha = 0.4
    }
}

// MARK: - Layout

extension BabyGenderSelector {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubview(styledView)
        styledView.addSubviews(titleLabel, girlButton, boyButton)
    }

    private func configureSubviews() {
        styledView.pin
            .top()
            .horizontally()
        
        titleLabel.pin
            .top()
            .horizontally(15)
            .sizeToFit(.width)
        
        girlButton.pin
            .below(of: titleLabel)
            .size(100)
            .right(to: styledView.edge.hCenter)
            .marginTop(10)
            .marginRight(10%)
        
        boyButton.pin
            .below(of: titleLabel)
            .size(100)
            .left(to: styledView.edge.hCenter)
            .marginTop(10)
            .marginLeft(10%)
        
        styledView.pin
            .wrapContent(.vertically, padding: Padding.inset(top: 10, bottom: 16))
    }
}
