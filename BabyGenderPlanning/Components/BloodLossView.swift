//
//  BloodLossView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout
import RxSwift
import RxCocoa

class BloodLossView: UIView {
    
    // MARK: - Observables
    
    var aboutBloodLossTapped: Observable<Void> {
        return bloodLossAboutButton.rx.tap.asObservable()
    }
    
    var bloodLossDate: Observable<Date?> {
        return showBloodLoss.flatMap { [weak self] showBloodLoss in
            return showBloodLoss ? self?.bloodLossDatePicker.rx.date.asObservable() ?? Observable.just(nil) : Observable.just(nil)
        }
    }
    
    // MARK: - Configuration Elements
    
    let needToUpdateLayout = PublishRelay<Void>()
    let loadedBloodLossDate = BehaviorRelay<Date?>(value: nil)
    let showBloodLoss = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()

    // MARK: - UI Elements
    
    private lazy var bloodLossIcon: UIImageView = {
        return UIImageView(image: Image.bloodLoss())
    }()

    private lazy var bloodLossTitle: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa
        label.text = Localized.bloodLoss()

        return label
    }()

    private lazy var bloodLossAboutButton: QuestionButton = {
        return QuestionButton()
    }()

    private lazy var bloodLossSwitch: GradientSwitch = {
        let bloodLossSwitch = GradientSwitch()
        
        return bloodLossSwitch
    }()
    
    fileprivate lazy var bloodLossDatePicker = DatePickerTextField(isFutureDateAllowed: false)
    
    private lazy var bloodLossInputView: LabeledInputView = {
        let view = LabeledInputView(inputView: bloodLossDatePicker)
        view.label.text = Localized.bloodLoss_date_title()
        view.label.numberOfLines = 0

        return view
    }()
    
    private lazy var bottomInset: UIView = {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }()

    // MARK: - Lifecycle

    init(disableShadow: Bool = false) {
        super.init(frame: .zero)
        
        if disableShadow {
            bloodLossDatePicker.disableShadow()
            bloodLossAboutButton.disableShadow()
        }
        
        (showBloodLoss <-> bloodLossSwitch.rx.isOn).disposed(by: disposeBag)
        
        showBloodLoss.mapToVoid().bind(to: needToUpdateLayout).disposed(by: disposeBag)
        
        needToUpdateLayout
            .asVoidDriver()
            .drive(onNext: { [unowned self] in self.updateLayout() })
            .disposed(by: disposeBag)
        
        loadedBloodLossDate
            .do(onNext: { [unowned self] in self.showBloodLoss.accept($0 != nil) })
            .bind(to: bloodLossDatePicker.rx.date)
            .disposed(by: disposeBag)
        
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayout() {
        setupSubviews()
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
}

// MARK: - Layout

extension BloodLossView {
    private func setupSubviews() {
        let allViews = [bloodLossIcon, bloodLossTitle, bloodLossAboutButton, bloodLossSwitch, bloodLossInputView, bottomInset]
        guard showBloodLoss.value else {
            removeSubviews(allViews)
            addSubviews(bloodLossIcon, bloodLossTitle, bloodLossAboutButton, bloodLossSwitch, bottomInset)
            return
        }
        addSubviews(allViews)
    }

    private func configureFrames() {
        bloodLossIcon.pin
            .height(11)
            .width(26)
            .left()
            .vCenter(to: bloodLossSwitch.edge.vCenter)
        
        bloodLossTitle.pin
            .after(of: bloodLossIcon, aligned: .center)
            .marginLeft(11)
            .sizeToFit()
        
        bloodLossAboutButton.pin
            .height(18)
            .width(18)
            .after(of: bloodLossTitle, aligned: .center)
            .marginLeft(10)
        
        bloodLossSwitch.pin
            .height(31)
            .width(51)
            .top()
            .after(of: bloodLossAboutButton)
            .right()
            .justify(.right)
                
        guard showBloodLoss.value else {
            pin.wrapContent(.vertically)
            
            return
        }
        
        bloodLossInputView.pin
            .height(44)
            .below(of: bloodLossSwitch)
            .horizontally()
            .marginTop(13)
        
        pin.wrapContent(.vertically)
    }
}

extension Reactive where Base: BloodLossView {
    var showDatePickerBorder: Binder<Bool> {
        return Binder(base) { view, result in
            let borderColor = UIColor.mulberry.cgColor
            let borderWidth: CGFloat = result ? 3 : 0
            
            view.bloodLossDatePicker.layer.borderColor = borderColor
            view.bloodLossDatePicker.layer.borderWidth = borderWidth
        }
    }
}
