//
//  DetailSavedResultView.swift
//  BabyGenderPlanning
//
//  Created by Alx Krw on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import PinLayout

final class DetailSavedResultView: UIView {
    private let presenter: DetailSavedResultPresenterProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    private lazy var headerView: HeaderTitleView = {
        let headerView = HeaderTitleView(
            title: "Calculate",
            isBackButton: true,
            optionsButtonImage: Image.delete()
        )
        
        return headerView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubviews(cardView)
                
        return scrollView
    }()
    
    private lazy var cardView: StyledView = {
        let view = StyledView(
            shadowRadius: 10,
            shadowOpacity: 0.4,
            shadowOffset: CGSize(width: 0, height: 4)
        )
        view.addSubviews(methodLabel,
                         parentDates,
                         genderImage,
                         genderConceptionDatesTitleLabel,
                         favorableDatesLabel,
                         viewForButton
        )
        
        return view
    }()
    
    private lazy var methodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .barossa
        label.font = .boldSystemFont(ofSize: 16)
                
        return label
    }()
    
    private lazy var parentDates = ResultParentsInfoView()

    private lazy var genderImage = UIImageView()
    
    private lazy var genderConceptionDatesTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .barossa
        label.font = .boldSystemFont(ofSize: 15)
                        
        return label
    }()
    
    private lazy var favorableDatesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
                
        return label
    }()
    
    private lazy var viewForButton: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        view.addSubviews(recomendationsButton)
        
        return view
    }()
    
    private lazy var recomendationsButton: GradientButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.recommendations_button_title(), for: .normal)
        
        return button
    }()

    // MARK: - Lifecycle
    
    init(_ presenter: DetailSavedResultPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
        
        backgroundColor = .appWhite
        
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(colors: .pink)
        configureSubviews()
    }
}

// MARK: - UI Bindings

extension DetailSavedResultView {
    private func setupBindings() {
        let input = DetailSavedResultPresenter.Input(
            backTrigger: headerView.menuButtonClicked,
            deleteTrigger: headerView.optionsButtonClicked ,
            recomendationTrigger: recomendationsButton.rx.tap.asObservable()
        )
        
        let output = presenter.buildOutput(with: input)
        output.calculationInfo.drive(onNext: { [weak self] calculateInfo in
            self?.headerView.title = "\(Localized.calculation()) \(calculateInfo.calculationDate.format(dateFormat: .ddMMYYYY))"
            self?.methodLabel.text = calculateInfo.method == .bloodRenewal ?
                Localized.bloodRenewalMethod() :
                Localized.freymanDobrotingMethod()
            self?.parentDates.fatherNameString = calculateInfo.getFatherName
            self?.parentDates.motherNameString = calculateInfo.getMotherName
            self?.genderImage.image = calculateInfo.gender == .male ?
                Image.aBoy() :
                Image.aGirl()
            self?.genderConceptionDatesTitleLabel.text = calculateInfo.gender == .male ?
                Localized.favorableConceptionDaysForBoy() :
                Localized.favorableConceptionDaysForGirl()
            self?.favorableDatesLabel.attributedText = calculateInfo.conceptionDatesStrings
        })
        .disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

extension DetailSavedResultView {
    
    private func setupSubviews() {
        addSubviews(headerView, scrollView)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        scrollView.pin
            .below(of: headerView)
            .bottom(pin.safeArea + 10)
            .horizontally(16)
        
        cardView.pin
            .vertically()
            .horizontally()
        
        methodLabel.pin
            .height(40)
            .hCenter()
            .width(80%)
            .vCenter()

        parentDates.pin
            .below(of: methodLabel)
            .height(99)
            .left(16)
            .right(16)

        genderImage.pin
            .vCenter(to: parentDates.edge.vCenter)
            .right(16)
            .sizeToFit()

        genderConceptionDatesTitleLabel.pin
            .below(of: genderImage)
            .marginTop(24)
            .horizontally(5)
            .sizeToFit(.width)

        favorableDatesLabel.pin
            .below(of: genderConceptionDatesTitleLabel)
            .horizontally(14)
            .sizeToFit(.width)
            .marginTop(24)

        viewForButton.pin
            .below(of: favorableDatesLabel)
            .horizontally()
            .height(103)
        
        recomendationsButton.pin
            .height(55)
            .width(275)
            .hCenter()
            .vCenter()
        
        cardView.pin.width(of: scrollView).wrapContent(.vertically)
        scrollView.updateContentSizeHeight()
    }
}
