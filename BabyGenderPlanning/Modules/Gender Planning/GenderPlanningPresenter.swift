//
//  GenderPlanningPresenter.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol GenderPlanningPresenterProtocol {
    func buildOutput(with input: GenderPlanningPresenter.Input) -> GenderPlanningPresenter.Output
}

protocol GenderPlanningReceiver: Receiver {
    func receiveParent(_ parent: ParentInfo)
    func receiveBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender)
}

final class GenderPlanningPresenter: Stepper {
    var steps = PublishRelay<Step>()

    private let interactor: GenderPlanningInteractor
    private let disposeBag = DisposeBag()

    private let messageRelay = PublishRelay<ToastMessage>()
    
    init(_ interactor: GenderPlanningInteractor) {
        self.interactor = interactor
    }
}

extension GenderPlanningPresenter: GenderPlanningReceiver {
    func receiveParent(_ parent: ParentInfo) {
        parent.gender == .male ?
            interactor.loadedFather.accept(parent):
            interactor.loadedMother.accept(parent)
    }
    
    func receiveBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender) {
        gender == .male ?
            interactor.fatherBloodGroup.accept(bloodGroup):
            interactor.motherBloodGroup.accept(bloodGroup)
    }
}

extension GenderPlanningPresenter: IsPresenter, GenderPlanningPresenterProtocol {
    struct Input {
        let backTrigger: Observable<Void>
        
        let needToUpdateLayout: Observable<Void>
        
        let fatherBirthdayDate: Observable<Date?>
        let fatherBloodGroup: Observable<BloodGroupInfo?>
        let fatherBloodLossDate: Observable<Date?>
        
        let motherBirthdayDate: Observable<Date?>
        let motherBloodGroup: Observable<BloodGroupInfo?>
        let motherBloodLossDate: Observable<Date?>
        
        let fatherDropDownAction: Observable<DropDownAction>
        let motherDropDownAction: Observable<DropDownAction>
        
        let conceptionPeriod: Observable<Int>
        let babyGender: Observable<Gender>
        
        let didSwitchCalculationMethod: Observable<Int>
        let didTapOnAboutFemaleBloodLoss: Observable<Void>
        let didTapOnAboutMaleBloodLoss: Observable<Void>
        let didTapOnCalculateButton: Observable<Void>
        let didTapOnFemaleBloodGroup: Observable<BloodGroupInfo?>
        let didTapOnMaleBloodGroup: Observable<BloodGroupInfo?>
        let didTapAboutMethod: Observable<Void>
        let didTapOnRecommendations: Observable<Void>
    }

    struct Output {
        let updateMenuButtonImage: Driver<UIImage?>
        let updateLayout: Driver<Void>
        let selectedMethod: Driver<CalculationMethod>
        let loadedFather: Driver<ParentInfo?>
        let loadedMother: Driver<ParentInfo?>
        let fatherBloodGroup: Driver<BloodGroupInfo>
        let motherBloodGroup: Driver<BloodGroupInfo>
        let planningResult: Driver<CalculationInfo?>
        let shouldScrollToBottom: Driver<Void>
        let message: Driver<ToastMessage>
    }

    func bindInput(_ input: GenderPlanningPresenter.Input) {
        
        input.backTrigger
            .withLatestFrom(interactor.fromPredictionScreen)
            .compactMap { isBackButton in
                guard isBackButton else {
                    Menu.toggle()
                    return nil
                }
                return RouteStep.pop
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapOnAboutFemaleBloodLoss
            .map { RouteStep.showContainer(for: .aboutBloodLoss(gender: .female)) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapOnAboutMaleBloodLoss
            .map { RouteStep.showContainer(for: .aboutBloodLoss(gender: .male)) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapOnMaleBloodGroup
            .map { RouteStep.showContainer(for: .bloodGroupPicker(gender: .male, bloodGroup: $0)) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapOnFemaleBloodGroup
            .map { RouteStep.showContainer(for: .bloodGroupPicker(gender: .female, bloodGroup: $0)) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapAboutMethod
            .withLatestFrom(input.didSwitchCalculationMethod)
            .compactMap(CalculationMethod.init)
            .map { $0 == .bloodRenewal ? Localized.about_bloodRenewal() : Localized.about_freymanDobrotin() }
            .map { RouteStep.showContainer(for: .insertableTextView(text: $0, title: Localized.page_title_aboutMethod())) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.fatherDropDownAction
            .map { [unowned self] action in
                switch action {
                case .loadParent:
                    return RouteStep.showContainer(for: .parentPicker(gender: .male))
                case .saveParent:
                    guard let father = self.interactor.father.value else { return nil }
                    return RouteStep.updateParent(parent: father)
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.motherDropDownAction
            .map { action in
                switch action {
                case .loadParent:
                    return RouteStep.showContainer(for: .parentPicker(gender: .female))
                case .saveParent:
                    guard let mother = self.interactor.mother.value else { return nil }
                    return RouteStep.updateParent(parent: mother)
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        let father = Observable
            .combineLatest(input.fatherBirthdayDate.compactMap { $0 },
                           input.fatherBloodGroup,
                           input.fatherBloodLossDate)
            .compactMap { [unowned self] in self.configureFather(birthdayDate: $0, bloodGroup: $1, bloodLossDate: $2) }
            .map { [unowned self] in self.compareFather(withFather: $0) }
        
        let mother = Observable
            .combineLatest(input.motherBirthdayDate.startWith(nil),
                           input.motherBloodGroup.startWith(nil),
                           input.motherBloodLossDate.startWith(nil))
            .compactMap { [unowned self] in self.configureMother(birthdayDate: $0, bloodGroup: $1, bloodLossDate: $2) }
            .map { [unowned self] in self.compareMother(withMother: $0) }
        
        father.bind(to: interactor.father).disposed(by: disposeBag)
        mother.bind(to: interactor.mother).disposed(by: disposeBag)
    }
    
    func configureOutput(_ input: GenderPlanningPresenter.Input) -> GenderPlanningPresenter.Output {
        let updateMenuButtonImage = interactor
            .fromPredictionScreen
            .asObservable()
            .map { fromPrediction in return fromPrediction ? Image.backArrow() : Image.menu() }
            .asDriver(onErrorJustReturn: Image.menu())
        
        let shouldUpdateLayout = Observable
            .merge(input.babyGender.mapToVoid(), input.needToUpdateLayout)
            .asVoidDriver()
        
        let selectedMethod = input.didSwitchCalculationMethod
            .skip(1)
            .compactMap(CalculationMethod.init)
            .asDriver(onErrorJustReturn: .freymanDobroting)
        
        let loadedFather = interactor.loadedFather
            .do(onNext: { [unowned self] in self.interactor.father.accept($0) })
            .asDriverOnErrorJustComplete()
        
        let loadedMother = interactor.loadedMother
            .do(onNext: { [unowned self] in self.interactor.mother.accept($0) })
            .asDriverOnErrorJustComplete()
        
        let fatherBloodGroup = interactor.fatherBloodGroup
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
        
        let motherBloodGroup = interactor.motherBloodGroup
            .compactMap { $0 }
            .asDriverOnErrorJustComplete()
        
        let requiredInputs = Observable
            .combineLatest(input.didSwitchCalculationMethod, input.babyGender, input.conceptionPeriod)
        
        let shouldClearPlanningResult: Driver<CalculationInfo?> = Observable
            .merge(input.didSwitchCalculationMethod.mapToVoid(),
                   input.babyGender.mapToVoid())
            .map { nil }
            .asDriverOnErrorJustComplete()
        
        let calculationInfo: Driver<CalculationInfo?> = input.didTapOnCalculateButton
            .withLatestFrom(requiredInputs)
            .map { [unowned self] calcMethodInt, babyGender, conceptionPeriod in
                return CalculationMethod(rawValue: calcMethodInt) == .bloodRenewal ?
                    self.calculateByBlood(with: conceptionPeriod, for: babyGender):
                    self.calculateByFreymanDobrotin(with: conceptionPeriod, for: babyGender)
            }
            .asDriver(onErrorJustReturn: nil)
            .do(onNext: { [unowned self] in self.saveCalculation($0) })
        
        input.didTapOnRecommendations
            .withLatestFrom(calculationInfo.asObservable())
            .compactMap { $0?.gender }
            .map { RouteStep.recommendations(gender: $0) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        let planningResult: Driver<CalculationInfo?> = Driver
            .merge(calculationInfo, shouldClearPlanningResult)
        
        let updateLayout = Driver
            .merge(shouldUpdateLayout,
                   planningResult.mapToVoid())
        
        let shouldScrollToBottom = planningResult.asObservable()
            .compactMap { $0 }
            .mapToVoid()
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriverOnErrorJustComplete()
        
        let message = messageRelay.asDriverOnErrorJustComplete()
        
        return Output(
            updateMenuButtonImage: updateMenuButtonImage,
            updateLayout: updateLayout,
            selectedMethod: selectedMethod,
            loadedFather: loadedFather,
            loadedMother: loadedMother,
            fatherBloodGroup: fatherBloodGroup,
            motherBloodGroup: motherBloodGroup,
            planningResult: planningResult,
            shouldScrollToBottom: shouldScrollToBottom,
            message: message
        )
    }
}

// MARK: - Private methods

private extension GenderPlanningPresenter {
    func saveCalculation(_ calculation: CalculationInfo?) {
        guard let calculation = calculation else { return }
        interactor.saveCalculation(calculation)
    }
    
    func compareFather(withFather father: ParentInfo) -> ParentInfo {
        guard let loadedFather = interactor.loadedFather.value else { return father }
    
        if loadedFather.birthdayDate == father.birthdayDate &&
            loadedFather.bloodGroup?.level == father.bloodGroup?.level &&
            loadedFather.bloodGroup?.rhesusFactor == father.bloodGroup?.rhesusFactor {
            return loadedFather
        } else {
            var newFather = father
            newFather.id = UUID().uuidString
            newFather.name = ""
            return newFather
        }
    }
    
    func compareMother(withMother mother: ParentInfo) -> ParentInfo {
        guard let loadedMother = interactor.loadedMother.value else { return mother }
        
        if loadedMother.birthdayDate == mother.birthdayDate &&
            loadedMother.bloodGroup?.level == mother.bloodGroup?.level &&
            loadedMother.bloodGroup?.rhesusFactor == mother.bloodGroup?.rhesusFactor {
            return loadedMother
        } else {
            var newMother = mother
            newMother.id = UUID().uuidString
            newMother.name = ""
            return newMother
        }
    }
}

// MARK: - Planning methods

private extension GenderPlanningPresenter {
    func calculateByBlood(with conceptionPeriod: Int, for gender: Gender) -> CalculationInfo? {
        guard let father = interactor.father.value,
            var mother = interactor.mother.value else {
                messageRelay.accept(.missingInput)
                return nil
        }

        if mother.bloodGroup == nil {
            mother.bloodGroup = BloodGroupInfo(id: "", level: 0, rhesusFactor: .positive)
        }

        guard let result = interactor.calculateByBlood(father: father, mother: mother, periodInMonth: conceptionPeriod, desiredGender: gender) else {
            messageRelay.accept(.noFavorableDates)
            return nil
        }
        return result
    }
    
    func calculateByFreymanDobrotin(with conceptionPeriod: Int, for gender: Gender) -> CalculationInfo? {
        guard let father = interactor.father.value,
            let mother = interactor.mother.value else {
                messageRelay.accept(.missingInput)
                return nil
        }
        
        guard let result = interactor
            .calculateByFreymanDobrotin(father: father, mother: mother, periodInMonth: conceptionPeriod, desiredGender: gender) else {
                messageRelay.accept(.noFavorableDates)
                return nil
        }
        return result
    }
}

// MARK: - Parent configuration

private extension GenderPlanningPresenter {
    func configureFather(birthdayDate: Date?, bloodGroup: BloodGroupInfo?, bloodLossDate: Date?) -> ParentInfo? {
        guard let birthdayDate = birthdayDate else { return nil }
        
        guard var father = interactor.father.value else {
            return ParentInfo(id: randomUUID, name: "", gender: .male, birthdayDate: birthdayDate, bloodGroup: bloodGroup, bloodLossDate: bloodLossDate)
        }
        
        father.birthdayDate = birthdayDate
        father.bloodGroup = bloodGroup
        father.bloodLossDate = bloodLossDate
        
        return father
    }
    
    func configureMother(birthdayDate: Date?, bloodGroup: BloodGroupInfo?, bloodLossDate: Date?) -> ParentInfo? {
        guard let birthdayDate = birthdayDate else { return nil }
        
        guard var mother = interactor.mother.value else {
            return ParentInfo(id: randomUUID, name: "", gender: .female, birthdayDate: birthdayDate, bloodGroup: bloodGroup, bloodLossDate: bloodLossDate)
        }
        
        mother.birthdayDate = birthdayDate
        mother.bloodGroup = bloodGroup
        mother.bloodLossDate = bloodLossDate
        
        return mother
    }
}
