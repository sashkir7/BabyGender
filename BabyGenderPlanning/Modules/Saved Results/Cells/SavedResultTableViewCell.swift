//
//  SavedResultTableViewCell.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SavedResultTableViewCell: UITableViewCell, ClassIdentifiable {

    // MARK: - Observables

    var delete: Observable<CalculationInfo> {
        return deleteButton.rx.tap
            .compactMap { [weak self] _ in
                self?.calculationInfo
            }
    }
    
    var recommendations: Observable<Gender> {
        return recommendationsButton.rx.tap
            .compactMap { [weak self] in
                self?.calculationInfo?.gender
            }
    }
    
    var allDates: Observable<CalculationInfo> {
        return showAllDatesButton.rx.tap
            .compactMap { [weak self] _ in
                self?.calculationInfo
            }
    }

    // MARK: - Properties
    
    private var calculationInfo: CalculationInfo?
    private(set) var disposeBag = DisposeBag()

    // MARK: - UI Elements

    private lazy var cardView: StyledView = {
        let view = StyledView(shadowRadius: 10, shadowOpacity: 0.4, shadowOffset: CGSize(width: 0, height: 4))
        view.addSubviews(titleLabel, methodLabel, parentDates, genderImage, deleteButton)
        view.addSubviews(showAllDatesButton, dateOfConception, recommendationsButton)

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localized.calculation()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var methodLabel: UILabel = {
        let label = UILabel()
        label.text = Localized.calculation()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var parentDates = ResultParentsInfoView()
    
    private lazy var genderImage: UIImageView = {
        return UIImageView()
    }()

    private lazy var deleteButton = ImageButton(image: Image.delete())
    
    private lazy var showAllDatesButton: IndentButton = {
        let button = IndentButton()
        button.setTitle(Localized.showAllDates(), for: .normal)
        button.setTitleColor(UIColor.mulberry, for: .normal)
        button.titleLabel?.font = UIFont.floatTitleFont.bold
        
        return button
    }()
    
    private lazy var dateOfConception: UILabel = {
        let label = UILabel()
        label.text = Localized.conceptionDate()
        label.font = .floatTitleFont
        label.textColor = .barossa
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var recommendationsButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.recommendations_button_title(), for: .normal)
        
        return button
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }

    internal func configure(calculationInfo: CalculationInfo) {
        self.calculationInfo = calculationInfo
        
        titleLabel.text = Localized.calculation() + " " +  calculationInfo.calculationDate.format(dateFormat: .ddMMYYYY)
        methodLabel.text =
            "(" +
            (calculationInfo.method == .freymanDobroting ? Localized.freymanDobrotingMethod() : Localized.bloodRenewalMethod())
            + ")"
        
        dateOfConception.text = Localized.conceptionDate() + (calculationInfo.conceptionPeriodString ?? "")
        genderImage.image = calculationInfo.gender == .male ? Image.aBoy() : Image.aGirl()
        
        parentDates.motherNameString = calculationInfo.getMotherName
        parentDates.fatherNameString = calculationInfo.getFatherName
        
        parentDates.setNeedsLayout()
        parentDates.layoutIfNeeded()
    }
}

// MARK: - Layout

extension SavedResultTableViewCell {
    private func setupSubviews() {
        addSubviews(cardView)
    }

    private func configureSubviews() {
        cardView.pin
            .vertically(4)
            .horizontally(16)
        
        titleLabel.pin
            .top(7)
            .horizontally()
            .sizeToFit(.width)
        
        deleteButton.pin
            .width(14)
            .height(18)
            .vCenter(to: titleLabel.edge.vCenter)
            .right(16)
        
        methodLabel.pin
            .below(of: titleLabel)
            .horizontally()
            .sizeToFit(.width)
            .marginTop(5)
        
        parentDates.pin
            .height(99)
            .below(of: methodLabel)
            .left(16)
            .right(16)
            .marginTop(16)
        
        genderImage.pin
            .vCenter(to: parentDates.edge.vCenter)
            .right(16)
            .sizeToFit()
        
        showAllDatesButton.pin
            .width(120)
            .below(of: parentDates)
            .right(16)
            .marginTop(30)
        
        dateOfConception.pin
            .vCenter(to: showAllDatesButton.edge.vCenter)
            .left(16)
            .before(of: showAllDatesButton)
            .sizeToFit(.width)
            .marginRight(10)
        
        recommendationsButton.pin
            .height(36)
            .below(of: showAllDatesButton)
            .horizontally(32)
            .marginTop(25)
    }
}
