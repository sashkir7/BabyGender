//
//  ParentPresenter.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol ParentPresenterProtocol {
    func buildOutput(with input: ParentPresenter.Input) -> ParentPresenter.Output
}

protocol ParentPresenterReceiver: Receiver {
    func receiveBloodGroup(_ bloodGroup: BloodGroupInfo)
}

final class ParentPresenter: Stepper {
    private let interactor: ParentInteractor
    
    var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
    
    private let showNameBorder = PublishRelay<Bool>()
    private let showBirthdayDateBorder = PublishRelay<Bool>()
    private let showBloodLossDateBorder = PublishRelay<Bool>()
    private let showMessage = PublishRelay<ToastMessage>()
    
    init(_ interactor: ParentInteractor) {
        self.interactor = interactor
    }
}

extension ParentPresenter: ParentPresenterReceiver {
    func receiveBloodGroup(_ bloodGroup: BloodGroupInfo) {
        interactor.bloodGroup.accept(bloodGroup)
    }
}

extension ParentPresenter: IsPresenter, ParentPresenterProtocol {
    struct Input {
        let backTrigger: Observable<Void>
        let saveTrigger: Observable<Void>
        
        let name: Observable<String?>
        let gender: Observable<Gender>
        let birthdayDate: Observable<Date?>
        let bloodGroup: Observable<BloodGroupInfo?>
        let bloodLossDate: Observable<Date?>
        
        let didTapBloodGroup: Observable<Void>
        let didTapAboutBloodLoss: Observable<Void>
    }
    
    struct Output {
        let name: Driver<String>
        let gender: Driver<Gender>
        let birthdayDate: Driver<Date>
        let bloodGroup: Driver<BloodGroupInfo?>
        let bloodLossDate: Driver<Date?>
        
        let showNameBorder: Driver<Bool>
        let showBirthdayDateBorder: Driver<Bool>
        let showBloodLossDateBorder: Driver<Bool>
        let message: Driver<ToastMessage>
    }
    
    func bindInput(_ input: Input) {
        input.backTrigger
            .map { [unowned self] in self.containsNewValues() }
            .bind(to: steps)
            .disposed(by: disposeBag)

        input.name
            .compactMap { $0 }
            .map { !($0.count > 0) }
            .bind(to: showNameBorder)
            .disposed(by: disposeBag)

        input.birthdayDate
            .map { $0 == nil }
            .bind(to: showBirthdayDateBorder)
            .disposed(by: disposeBag)

        input.name.skip(1).map { $0?.trim(to: 20) }.bind(to: interactor.name).disposed(by: disposeBag)
        input.gender.skip(1).bind(to: interactor.gender).disposed(by: disposeBag)
        input.birthdayDate.skip(1).bind(to: interactor.birthdayDate).disposed(by: disposeBag)
        input.bloodGroup.skip(1).bind(to: interactor.bloodGroup).disposed(by: disposeBag)
        input.bloodLossDate.skip(1).bind(to: interactor.bloodLossDate).disposed(by: disposeBag)
        
        input.didTapBloodGroup
            .withLatestFrom(interactor.bloodGroup)
            .map { ReusableView.bloodGroupPicker(gender: .unknown, bloodGroup: $0) }
            .map(RouteStep.showContainer)
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapAboutBloodLoss
            .withLatestFrom(interactor.gender)
            .map(ReusableView.aboutBloodLoss(gender:))
            .map(RouteStep.showContainer)
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
        
    func configureOutput(_ input: ParentPresenter.Input) -> ParentPresenter.Output {
        let parentOnSave = input
            .saveTrigger
            .map { [unowned self] in self.checkRequiredInputs() }
            .map { [unowned self] in self.setupParent() }
        
        parentOnSave
            .compactMap { $0 }
            
            .map { [unowned self] parent in self.interactor.saveParent(parent) }
            .filter { $0 }
            .map { _ in RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        let name = interactor.name.compactMap { $0 }.asDriver(onErrorJustReturn: "")
        let gender = interactor.gender.asDriver(onErrorJustReturn: .male)
        let birthdayDate = interactor.birthdayDate.compactMap { $0 }.asDriver(onErrorJustReturn: Date())
        let bloodGroup = interactor.bloodGroup.asDriver(onErrorJustReturn: nil)
        let bloodLossDate = interactor.bloodLossDate.asDriver(onErrorJustReturn: nil)
        
        let showNameBorder = self.showNameBorder.asDriver(onErrorJustReturn: false)
        let showBirthdayDateBorder = self.showBirthdayDateBorder.asDriver(onErrorJustReturn: false)
        let showBloodLossDateBorder = self.showBloodLossDateBorder.asDriver(onErrorJustReturn: false)
        
        let message = showMessage.asDriverOnErrorJustComplete()
        
        return Output(name: name,
                      gender: gender,
                      birthdayDate: birthdayDate,
                      bloodGroup: bloodGroup,
                      bloodLossDate: bloodLossDate,
                      showNameBorder: showNameBorder,
                      showBirthdayDateBorder: showBirthdayDateBorder,
                      showBloodLossDateBorder: showBloodLossDateBorder,
                      message: message)
    }
}

// MARK: - Helper methods

private extension ParentPresenter {
    func setupParent() -> ParentInfo? {
        guard let birthdayDate = interactor.birthdayDate.value,
            let name = interactor.name.value,
            !name.isEmpty else { return nil }
        
        if let bloodLossDate = interactor.bloodLossDate.value, bloodLossDate < birthdayDate {
            return nil
        }
        
        return ParentInfo(
            id: interactor.id,
            name: name,
            gender: interactor.gender.value,
            birthdayDate: birthdayDate,
            bloodGroup: interactor.bloodGroup.value,
            bloodLossDate: interactor.bloodLossDate.value
        )
    }
    
    func checkRequiredInputs() {
        let nameResult = interactor.name.value?.isEmpty ?? true
        let birthdayDateResult = interactor.birthdayDate.value == nil
        
        showNameBorder.accept(nameResult)
        showBirthdayDateBorder.accept(birthdayDateResult)
        showBirthdayDateBorder.accept(birthdayDateResult)
        
        guard nameResult || birthdayDateResult else {
            if let bloodLossDate = interactor.bloodLossDate.value,
                let birthdayDate = interactor.birthdayDate.value,
                bloodLossDate < birthdayDate {
                showBloodLossDateBorder.accept(true)
                showMessage.accept(.bloodLossDateInvalid)
            }
            return
        }
        showMessage.accept(.missingInput)
    }
    
    func containsNewValues() -> RouteStep {
        let routePop = RouteStep.pop
        let routeAlert = RouteStep.backParent { _ in self.steps.accept(RouteStep.pop) }
        
        guard let oldParent = interactor.initialParentInfo.value, let currentParent = setupParent() else {
            return isAllValuesEmpty() ? routePop : routeAlert
        }
        
        return oldParent == currentParent ? routePop : routeAlert
    }
    
    func isAllValuesEmpty() -> Bool {
        let isEmptyName = interactor.name.value?.isEmpty ?? true
        let isEmptyBirthdayDate = interactor.birthdayDate.value == nil
        let isNilBloodGroup = interactor.bloodGroup.value == nil
        let isNilBloodLossDate = interactor.bloodLossDate.value == nil
        
        return isEmptyName && isEmptyBirthdayDate && isNilBloodGroup && isNilBloodLossDate
    }
}
