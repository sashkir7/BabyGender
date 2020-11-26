//
//  ParentsPredictionView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 19.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout
import RxSwift
import RxCocoa

class ParentsInputView: UIView {
    
    // MARK: - Observables
    
    var showMaleAboutBloodLoss: Observable<Void> {
        return maleParentView.aboutBloodLossTapped
    }
    
    var showFemaleAboutBloodLoss: Observable<Void> {
        return femaleParentView.aboutBloodLossTapped
    }
    
    var showMaleBloodGroupPicker: Observable<BloodGroupInfo?> {
        return maleParentView.didTapOnBloodGroup
    }
    
    var showFemaleBloodGroupPicker: Observable<BloodGroupInfo?> {
        return femaleParentView.didTapOnBloodGroup
    }
    
    // Father inputs
    
    var fatherBirthdayDate: Observable<Date?> {
        return maleParentView.birthdayDate.asObservable()
    }
    
    var fatherBloodGroup: Observable<BloodGroupInfo?> {
        return maleParentView.bloodGroup.asObservable()
    }
    
    var fatherBloodLossDate: Observable<Date?> {
        let loadedDate = loadedFather.map { $0?.bloodLossDate }
        return Observable.merge(maleParentView.bloodLossDate, loadedDate)
    }
    
    var fatherDropDownAction: Observable<DropDownAction> {
        return maleParentView.didSelectDropDownAction
    }
    
    // Mother inputs
    
    var motherBirthdayDate: Observable<Date?> {
        return femaleParentView.birthdayDate.asObservable()
    }
    
    var motherBloodGroup: Observable<BloodGroupInfo?> {
        return femaleParentView.bloodGroup.asObservable()
    }
    
    var motherBloodLossDate: Observable<Date?> {
        let loadedDate = loadedMother.map { $0?.bloodLossDate }
        return Observable.merge(femaleParentView.bloodLossDate, loadedDate)
    }
    
    var motherDropDownAction: Observable<DropDownAction> {
        return femaleParentView.didSelectDropDownAction
    }
    
    // MARK: - Configuration Elements
    let loadedMother = BehaviorRelay<ParentInfo?>(value: nil)
    let loadedFather = BehaviorRelay<ParentInfo?>(value: nil)
    
    let setFatherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    let setMotherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    
    let selectedMethod = BehaviorRelay<CalculationMethod>(value: .freymanDobroting)
    
    var needToUpdate = PublishRelay<Void>()
    private(set) var disposeBag = DisposeBag()

    // MARK: - UI Elements
    
    private lazy var femaleParentView: ParentInputView = {
        let view = ParentInputView(gender: .female)
        view.needToUpdate.bind(to: needToUpdate).disposed(by: disposeBag)
        return view
    }()
    
    private lazy var maleParentView: ParentInputView = {
        let view = ParentInputView(gender: .male)
        view.needToUpdate.bind(to: needToUpdate).disposed(by: disposeBag)
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
    
    private func setupBindings() {
        needToUpdate.asVoidDriver().drive(onNext: (updateLayout)).disposed(by: disposeBag)
        selectedMethod
            .bind(to: femaleParentView.rx.selectedMethod, maleParentView.rx.selectedMethod)
            .disposed(by: disposeBag)
        
        loadedMother
            .subscribe(onNext: { [unowned self] in self.loadMother(parent: $0) })
            .disposed(by: disposeBag)
        
        loadedFather
            .subscribe(onNext: { [unowned self] in self.loadFather(parent: $0) })
            .disposed(by: disposeBag)
        
        setMotherBloodGroup.bind(to: femaleParentView.bloodGroup).disposed(by: disposeBag)
        setFatherBloodGroup.bind(to: maleParentView.bloodGroup).disposed(by: disposeBag)
    }
    
    private func loadFather(parent: ParentInfo?) {
        maleParentView.birthdayDate.accept(parent?.birthdayDate)
        maleParentView.bloodGroup.accept(parent?.bloodGroup)
        maleParentView.bloodLossDateRelay.accept(parent?.bloodLossDate)
    }
    
    private func loadMother(parent: ParentInfo?) {
        femaleParentView.birthdayDate.accept(parent?.birthdayDate)
        femaleParentView.bloodGroup.accept(parent?.bloodGroup)
        femaleParentView.bloodLossDateRelay.accept(parent?.bloodLossDate)
    }
}

// MARK: - Private Methods

extension ParentsInputView {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubviews(femaleParentView, maleParentView)
    }
    
    private func configureFrames() {
        femaleParentView.pin
            .top()
            .horizontally()
        
        maleParentView.pin
            .below(of: femaleParentView)
            .horizontally()
            .marginTop(10)
    }
}
