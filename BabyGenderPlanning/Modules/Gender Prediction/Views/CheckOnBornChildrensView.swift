//
//  CheckOnBornChidlrensView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 15/03/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout
import RxCocoa
import RxSwift

class CheckOnBornChildrensView: UIView {
    
    // MARK: - Observables
    
    var bornChildData: Observable<BornChildData?> {
        return babyInputView.bornChildData
    }

    let showBornChildrens = BehaviorRelay<Bool>(value: false)

    var didSwitchCheckOnBornChildren: Observable<Bool> {
        return isBornChildrensSwitch.rx.isOn.asObservable()
    }
    
    // MARK: - Configuration Elements
    
    var needToUpdate = PublishRelay<Void>()
    private(set) var disposeBag = DisposeBag()
    
    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .titleFont
        label.text = Localized.checkOnBornChildrens()
        label.textColor = UIColor.barossa.withAlphaComponent(0.7)
        label.numberOfLines = 0

        return label
    }()

    private lazy var isBornChildrensSwitch: GradientSwitch = {
        let gradientSwitch = GradientSwitch()

        return gradientSwitch
    }()

    private(set) lazy var babyInputView: BabyInputView = {
        return BabyInputView(frame: .zero)
    }()

    private lazy var predictionView: StyledView = {
        let view = StyledView()
        view.layer.cornerRadius = 4
        view.addSubviews(predictionLabel)

        return view
    }()

    private(set) lazy var predictionLabel: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = nil

        return label
    }()
    
    private var allViews = [UIView]()
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        (showBornChildrens <-> isBornChildrensSwitch.rx.isOn).disposed(by: disposeBag)

        showBornChildrens
            .mapToVoid()
            .bind(to: needToUpdate)
            .disposed(by: disposeBag)

        allViews = [titleLabel, isBornChildrensSwitch, babyInputView, predictionView]
        needToUpdate.asVoidDriver().drive(onNext: (updateLayout)).disposed(by: disposeBag)
        
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    func updatePrediction(_ prediction: String?) {
        predictionLabel.text = prediction
        needToUpdate.accept(())
    }
}

// MARK: - Layout

extension CheckOnBornChildrensView {
    private func updateLayout() {
        setupSubviews()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        guard isBornChildrensSwitch.isOn else {
            removeSubviews(allViews)
            addSubviews(titleLabel, isBornChildrensSwitch)
            return
        }
        
        addSubviews(allViews)
    }

    private func configureSubviews() {
        isBornChildrensSwitch.pin
            .top()
            .right(4)
        
        titleLabel.pin
            .left(4)
            .before(of: isBornChildrensSwitch)
            .vCenter(to: isBornChildrensSwitch.edge.vCenter)
            .sizeToFit(.width)
            .marginRight(10)
        
        guard isBornChildrensSwitch.isOn else { return }

        babyInputView.pin
            .height(144)
            .below(of: isBornChildrensSwitch)
            .horizontally()
            .marginTop(15)

        predictionLabel.pin
            .center(to: predictionView.anchor.center)
            .sizeToFit()
        
        guard predictionLabel.text != nil else {
            predictionView.pin
                .height(0)
                .below(of: babyInputView)
                .horizontally()
            
            return
        }
        
        predictionView.pin
            .height(40)
            .below(of: babyInputView)
            .horizontally()
            .marginTop(16)
    }
}
