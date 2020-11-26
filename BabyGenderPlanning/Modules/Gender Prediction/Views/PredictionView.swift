//
//  PredictionView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 08/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PredictionView: UIView {
    
    // MARK: - Observables
    
    var didTapOnPlanButton: Observable<Void> {
        return planningButton.rx.tap.asObservable()
    }
    
    // MARK: - Configuration elements
   
    var prediction: PredictionResult? {
        didSet { updateBabyPrediction(with: prediction) }
    }
    
    var needToUpdate = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var containerView: StyledView = {
        return StyledView()
    }()

    private lazy var babyPredictionView: BabyPredictionView = {
        let view = BabyPredictionView(gender: .male)
        view.needToUpdate.bind(to: needToUpdate).disposed(by: disposeBag)
        return view
    }()
    
    private lazy var planningButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.planning_button_title(), for: .normal)

        return button
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
        
        needToUpdate.subscribe(onNext: (updateLayout)).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    private func updateBabyPrediction(with prediction: PredictionResult?) {
        guard let prediction = prediction else {
            isHidden = true
            return
        }
        
        isHidden = false
        
        switch prediction {
        case let .defaultCalculation(gender):
            let image = gender == .male ? Image.aBoy() : Image.aGirl()
            let text = gender == .male ? Localized.youHaveABoy() : Localized.youHaveAGirl()
            babyPredictionView.genderIcon.accept(image)
            babyPredictionView.titleText.accept(text)
            babyPredictionView.dates.accept([])
            
        case let .checkOnBornChildren(gender, dates):
            let image = gender == .male ? Image.aBoy() : Image.aGirl()
            let text = gender == .male ? Localized.doYouHaveABoy() : Localized.doYouHaveAGirl()
            babyPredictionView.genderIcon.accept(image)
            babyPredictionView.titleText.accept(text)
            babyPredictionView.dates.accept(dates)
        }
        
        updateLayout()
    }
}

// MARK: - Layout

extension PredictionView {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubviews(containerView, planningButton)
        containerView.addSubview(babyPredictionView)
    }

    private func configureSubviews() {
        containerView.pin
            .top()
            .horizontally()
        
        babyPredictionView.pin
            .top()
            .horizontally()
            .wrapContent(.vertically)
        
        planningButton.pin
            .height(55)
            .width(275)
            .below(of: containerView)
            .hCenter()
            .marginTop(16)
        
        containerView.pin.wrapContent(.vertically, padding: Padding.inset(top: 16, bottom: 16))
    }
}

// MARK: - Reactive

extension Reactive where Base: PredictionView {
    var prediction: Binder<PredictionResult?> {
        return Binder(base) { view, result in
            view.prediction = result
        }
    }
}
