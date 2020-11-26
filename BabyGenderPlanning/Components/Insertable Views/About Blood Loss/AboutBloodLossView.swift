//
//  AboutBloodLossView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 28.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

final class AboutBloodLossView: UIView, InsertableView {
    var newStepObservable: Observable<RouteStep> = .empty()
    var dismissObservable: Observable<Void> = .empty()
    
    private let disposeBag = DisposeBag()
    private var gender = Gender.female
    
    // MARK: - UI Elements
    
    private lazy var styledView: StyledView = {
        return StyledView()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.generalTextFont.semibold
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Localized.bloodLoss()

        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Localized.lastDateOfBloodLossRequired()

        return label
    }()
    
    private lazy var relatedSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.generalTextFont.semibold
        label.textColor = .barossa
        label.numberOfLines = 0
        label.text = Localized.relatedToBloodLoss()
        
        return label
    }()
    
    private lazy var closeButton: ImageButton = {
        let button = ImageButton(image: Image.unionMin())
        return button
    }()
    
    private lazy var laparoscopyTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.laparoscopy())
    }()
    
    private lazy var bloodTransitionTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.bloodTransition())
    }()
    
    private lazy var bloodDonationTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.bloodDonation())
    }()
    
    private lazy var accidentTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.accident())
    }()
    
    private lazy var givingBirthTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.givingBirth())
    }()
    
    private lazy var abortionTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.abortion())
    }()
    
    private lazy var fetalLossTypeView: BloodLossTypeView = {
        return BloodLossTypeView(text: Localized.fetalLoss())
    }()
    
    // MARK: - Lifecycle

    init(gender: Gender) {
        super.init(frame: .zero)
        self.gender = gender

        setupBindings()
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

// MARK: - UI Bindings

extension AboutBloodLossView {
    private func setupBindings() {
        let tappedOutsied = rx.tapGesture()
            .when(.recognized)
            .filter { [unowned self] gesture in
                let location = gesture.location(in: self)
                return !self.styledView.frame.contains(location)
            }
            .mapToVoid()
        
        let tappedCloseButton = closeButton.rx.tap.asObservable()
        
        dismissObservable = Observable.merge(tappedOutsied, tappedCloseButton)
    }
}

// MARK: - Layout

extension AboutBloodLossView {
    func configureLayout() {
        pin.vertically().horizontally()
    }
    
    private func setupSubviews() {
        addSubview(styledView)
        styledView.addSubviews(titleLabel, closeButton, descriptionLabel, relatedSubtitleLabel)
        styledView.addSubviews(laparoscopyTypeView, bloodTransitionTypeView, bloodDonationTypeView, accidentTypeView)
        guard gender == .female else { return }
        styledView.addSubviews(givingBirthTypeView, abortionTypeView, fetalLossTypeView)
    }
    
    private func configureSubviews() {
        styledView.pin
            .vCenter()
            .horizontally(16)
        
        titleLabel.pin
            .height(22)
            .top()
            .horizontally(13)
        
        closeButton.pin
            .size(14)
            .top()
            .right(12)
        
        descriptionLabel.pin
            .below(of: titleLabel)
            .horizontally(16)
            .sizeToFit(.width)
            .marginTop(2)
        
        relatedSubtitleLabel.pin
            .height(22)
            .below(of: descriptionLabel)
            .horizontally(16)
            .marginTop(6)
        
        laparoscopyTypeView.pin
            .below(of: relatedSubtitleLabel)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        bloodTransitionTypeView.pin
            .below(of: laparoscopyTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        bloodDonationTypeView.pin
            .below(of: bloodTransitionTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        accidentTypeView.pin
            .below(of: bloodDonationTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        guard gender == .female else {
            styledView.pin.wrapContent(.vertically, padding: Padding.inset(top: 13, bottom: 16))
            
            return
        }
        
        givingBirthTypeView.pin
            .below(of: accidentTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        abortionTypeView.pin
            .below(of: givingBirthTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        fetalLossTypeView.pin
            .below(of: abortionTypeView)
            .horizontally(16)
            .marginTop(4)
            .wrapContent(.vertically)
        
        styledView.pin.wrapContent(.vertically, padding: Padding.inset(top: 13, bottom: 16))
    }
}
