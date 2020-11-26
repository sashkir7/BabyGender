//
//  BabyPredictionView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 08/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BabyPredictionView: UIView {
    private(set) var needToUpdate = PublishRelay<Void>()
    private(set) var genderIcon = PublishRelay<UIImage?>()
    private(set) var titleText = PublishRelay<String?>()
    private(set) var dates = PublishRelay<[Date]>()
    
    private let disposeBag = DisposeBag()

    // MARK: - UI Elements

    private lazy var iconImageView: UIImageView = {
        return UIImageView()
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var datesLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()

    init(gender: Gender) {
        super.init(frame: .zero)

        setupSubviews()

        iconImageView.image = gender == .male ? Image.aBoy() : Image.aGirl()
        titleLabel.text = gender == .male ? Localized.youHaveABoy() : Localized.youHaveAGirl()
        
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    private func setupBindings() {
        genderIcon.bind(to: iconImageView.rx.image).disposed(by: disposeBag)
        titleText.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        dates.map(formatDatesToText).bind(to: datesLabel.rx.text).disposed(by: disposeBag)
        
        Observable.zip(genderIcon, titleText, dates)
            .mapToVoid()
            .bind(to: needToUpdate)
            .disposed(by: disposeBag)
        
        needToUpdate.subscribe(onNext: (updateLayout)).disposed(by: disposeBag)
    }

    private func formatDatesToText(dates: [Date]) -> String? {
        guard !dates.isEmpty else { return nil }

        return dates.map { $0.format(dateFormat: .ddMMYYYY) }.joined(separator: "\n")
    }
}

// MARK: - Layout

extension BabyPredictionView {
    private func updateLayout() {
        configureSubviews()
    }
    
    private func setupSubviews() {
        addSubviews(iconImageView, titleLabel, datesLabel)
    }

    private func configureSubviews() {
        iconImageView.pin
            .top()
            .hCenter()
            .sizeToFit()
        
        titleLabel.pin
            .below(of: iconImageView)
            .horizontally()
            .sizeToFit(.width)
            .marginHorizontal(10)
        
        datesLabel.pin
            .below(of: titleLabel)
            .horizontally()
            .sizeToFit(.width)
    }
}
