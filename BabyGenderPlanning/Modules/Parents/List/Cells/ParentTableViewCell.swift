//
//  ParentTableViewCell.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ParentTableViewCell: UITableViewCell, ClassIdentifiable {

    // MARK: - Observables

    var edit: Observable<ParentInfo> {
        return headerView.editButton.rx.tap
            .compactMap { [weak self] _ in
                self?.parent
            }
    }

    var delete: Observable<ParentInfo> {
        return headerView.deleteButton.rx.tap
            .compactMap { [weak self] _ in
                self?.parent
            }
    }

    // MARK: - Properties

    private let noBloodLoss = 0
    private let bloodLossExist = 1

    private var currentState = 0

    private var parent: ParentInfo?

    private(set) var disposeBag = DisposeBag()

    // MARK: - UI Elements

    private lazy var cardView: StyledView = {
        let view = StyledView(shadowRadius: 10, shadowOpacity: 0.4, shadowOffset: CGSize(width: 0, height: 4))
        view.addSubviews(backgroundIconImageView, headerView, generalInfoView, additionalInfoView)

        return view
    }()

    private(set) lazy var headerView: ParentHeaderView = {
        return ParentHeaderView()
    }()

    private lazy var backgroundIconImageView: UIImageView = {
        return UIImageView()
    }()

    private lazy var generalInfoView: ParentGeneralInfoView = {
        return ParentGeneralInfoView()
    }()

    private lazy var additionalInfoView: ParentAdditionalInfoView = {
        return ParentAdditionalInfoView()
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

    internal func configure(parent: ParentInfo) {
        self.parent = parent
        
        currentState = parent.bloodLossDate == nil ? noBloodLoss : bloodLossExist

        backgroundIconImageView.image = parent.gender == .male ? Image.maleSymbol() : Image.femaleSymbol()
        backgroundIconImageView.contentMode = .scaleAspectFit
        headerView.configure(parent: parent)
        generalInfoView.configure(parent: parent)

        additionalInfoView.isHidden = true

        guard let bloodLossDate = parent.bloodLossDate else { return }
        additionalInfoView.isHidden = false
        additionalInfoView.configure(bloodLossDate: bloodLossDate)
    }
    
    internal func hideHeaderButtons() {
        headerView.deleteButton.isHidden = true
        headerView.editButton.isHidden = true
    }
}

// MARK: - Layout

extension ParentTableViewCell {
    private func setupSubviews() {
        addSubviews(cardView)
    }

    private func configureSubviews() {
        cardView.pin
            .vertically(4)
            .horizontally(16)
        
        backgroundIconImageView.pin
            .size(86)
            .center()
        
        headerView.pin
            .height(38)
            .top(3)
            .horizontally()
        
        generalInfoView.pin
            .height(56)
            .below(of: headerView)
            .horizontally()
            .marginTop(10)
        
        additionalInfoView.pin
            .height(46)
            .below(of: generalInfoView)
            .horizontally()
            .marginTop(20)
    }
}
