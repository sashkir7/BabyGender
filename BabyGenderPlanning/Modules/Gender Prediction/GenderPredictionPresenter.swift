//
//  GenderPredictionPresenter.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol GenderPredictionPresenterProtocol {
    func buildOutput(with input: GenderPredictionPresenter.Input) -> GenderPredictionPresenter.Output
}

protocol GenderPredictionReceiver: Receiver {
    func receiveParent(_ parent: ParentInfo)
    func receiveBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender)
    
    func clearData()
}

final class GenderPredictionPresenter: Stepper {
    var steps = PublishRelay<Step>()

    private let interactor: GenderPredictionInteractor
    private let disposeBag = DisposeBag()

    private let messageRelay = PublishRelay<ToastMessage>()
    
    init(_ interactor: GenderPredictionInteractor) {
        self.interactor = interactor
    }
}

extension GenderPredictionPresenter: GenderPredictionReceiver {
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
    
    func clearData() {
        interactor.clearAllData.accept(())
    }
}

extension GenderPredictionPresenter: IsPresenter, GenderPredictionPresenterProtocol {
    struct Input {
        let needToUpdate: Observable<Void>
        
        let fatherBirthdayDate: Observable<Date?>
        let fatherBloodGroup: Observable<BloodGroupInfo?>
        let fatherBloodLossDate: Observable<Date?>
        
        let motherBirthdayDate: Observable<Date?>
        let motherBloodGroup: Observable<BloodGroupInfo?>
        let motherBloodLossDate: Observable<Date?>
        
        let fatherDropDownAction: Observable<DropDownAction>
        let motherDropDownAction: Observable<DropDownAction>
        
        let conceptionDate: Observable<Date?>
        
        let didScrollView: Observable<Void>
        let didSwitchCalculationMethod: Observable<Int>
        let didTapAboutMethod: Observable<Void>
        let didSwitchCheckOnBornChildren: Observable<Bool>
        let didChangeBornChildData: Observable<BornChildData?>
        let didTapOnAboutFemaleBloodLoss: Observable<Void>
        let didTapOnAboutMaleBloodLoss: Observable<Void>
        let didTapOnCalculateButton: Observable<Void>
        let didTapOnFemaleBloodGroup: Observable<BloodGroupInfo?>
        let didTapOnMaleBloodGroup: Observable<BloodGroupInfo?>
        let didTapOnPlanButton: Observable<Void>
    }

    struct Output {
        let clearAllData: Driver<Void>
        let shouldUpdateLayout: Driver<Void>
        let selectedMethod: Driver<CalculationMethod>
        let conceptionPrediction: Driver<String?>
        let shouldHideEstimatedDateView: Driver<Bool>
        let loadedFather: Driver<ParentInfo?>
        let loadedMother: Driver<ParentInfo?>
        let fatherBloodGroup: Driver<BloodGroupInfo>
        let motherBloodGroup: Driver<BloodGroupInfo>
        let predictionResult: Driver<PredictionResult?>
        let shouldScrollToBottom: Driver<Void>
        let message: Driver<ToastMessage>
    }

    func bindInput(_ input: GenderPredictionPresenter.Input) {
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
            .compactMap { [unowned self] action -> RouteStep? in
                guard self.interactor.isSubscriptionActive.value else {
                    return .premium(fromMenu: false)
                }
                
                switch action {
                case .loadParent:
                    return .showContainer(for: .parentPicker(gender: .male))
                case .saveParent:
                    guard let father = self.interactor.father.value else { return nil }
                    
                    return .updateParent(parent: father)
                default:
                    return nil
                }
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.motherDropDownAction
            .compactMap { [unowned self] action -> RouteStep? in
                guard self.interactor.isSubscriptionActive.value else {
                    return .premium(fromMenu: false)
                }

                switch action {
                case .loadParent:
                    return .showContainer(for: .parentPicker(gender: .female))
                case .saveParent:
                    guard let mother = self.interactor.mother.value else { return nil }
                    return .updateParent(parent: mother)
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        let father = Observable
            .combineLatest(input.fatherBirthdayDate.startWith(nil),
                           input.fatherBloodGroup.startWith(nil),
                           input.fatherBloodLossDate.startWith(nil))
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
        input.conceptionDate.bind(to: interactor.conceptionDate).disposed(by: disposeBag)
        
        let parents = Observable.combineLatest(interactor.father, interactor.mother)
        
        input.didTapOnPlanButton
            .withLatestFrom(parents)
            .map { parents -> RouteStep in
                guard self.interactor.isSubscriptionActive.value else {
                    return .premium(fromMenu: false)
                }

                return .planning(father: parents.0, mother: parents.1)
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: GenderPredictionPresenter.Input) -> GenderPredictionPresenter.Output {
        let selectedMethod = input.didSwitchCalculationMethod
            .skip(1)
            .compactMap(CalculationMethod.init)
            .asDriver(onErrorJustReturn: .freymanDobroting)
        
        let didChangeConfiguration = Observable
            .merge(input.didSwitchCalculationMethod.mapToVoid(),
                   input.didSwitchCheckOnBornChildren.mapToVoid())
            .skip(1)
            .mapToVoid()
            .asVoidDriver()
        
        let conceptionPrediction = input.didChangeBornChildData
            .do(onNext: { [unowned self] in self.interactor.bornChild.accept($0) })
            .map { [unowned self] in self.interactor.getDatesOfConceptionText(with: $0) }
            .asDriver(onErrorJustReturn: nil)
        
        let shouldHideEstimatedDateView = input.didSwitchCheckOnBornChildren
            .asDriver(onErrorJustReturn: false)
        
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
        
        let predictionParameters = Observable
            .combineLatest(input.didSwitchCalculationMethod.compactMap(CalculationMethod.init),
                           input.didSwitchCheckOnBornChildren)
        
        let shouldClearPrediction: Observable<PredictionResult?> = input.didSwitchCheckOnBornChildren
            .map { _ in nil }
        
        let prediction = input.didTapOnCalculateButton
            .withLatestFrom(predictionParameters)
            .map { [unowned self] method, isCheckOnBornChildren -> PredictionResult? in
                guard method == .freymanDobroting else {
                    return self.calculateByBlood(withBornChildData: isCheckOnBornChildren)
                }
                return self.calculateByFreymanDobrotin(withBornChildData: isCheckOnBornChildren)
            }
            .map { [unowned self] prediction in
                self.checkGender(with: prediction)
            }
        
        let predictionResult = Observable
            .merge(prediction, shouldClearPrediction)
            .asDriverOnErrorJustComplete()
        
        let shouldUpdateLayout = Driver
            .merge(didChangeConfiguration,
                   predictionResult.mapToVoid(),
                   input.needToUpdate.asVoidDriver())
        
        let shouldScrollToBottom = predictionResult.asObservable()
            .compactMap { $0 }
            .mapToVoid()
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriverOnErrorJustComplete()
        
        let message = messageRelay.asDriverOnErrorJustComplete()
        
        let clearAllData = interactor.clearAllData
            .do(onNext: { [weak self] in
                self?.interactor.setNilValues()
            })
            .asVoidDriver()
        
        return Output(
            clearAllData: clearAllData,
            shouldUpdateLayout: shouldUpdateLayout,
            selectedMethod: selectedMethod,
            conceptionPrediction: conceptionPrediction,
            shouldHideEstimatedDateView: shouldHideEstimatedDateView,
            loadedFather: loadedFather,
            loadedMother: loadedMother,
            fatherBloodGroup: fatherBloodGroup,
            motherBloodGroup: motherBloodGroup,
            predictionResult: predictionResult,
            shouldScrollToBottom: shouldScrollToBottom,
            message: message
        )
    }
}

// MARK: - Prediction

private extension GenderPredictionPresenter {
    func calculateByBlood(withBornChildData: Bool) -> PredictionResult? {
        return withBornChildData ?
            calculateWithBornChildByBlood() :
            calculateByBlood()
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
    
    
    func calculateByFreymanDobrotin(withBornChildData: Bool) -> PredictionResult? {
        return withBornChildData ?
            calculateWithBornChildByFreymanDobrotin() :
            calculateByFreymanDobrotin()
    }
    
    // MARK: - Calculate by blood methods
    
    func calculateWithBornChildByBlood() -> PredictionResult? {
        guard let father = interactor.father.value,
            let mother = interactor.mother.value,
            let bornChildData = interactor.bornChild.value else {
                messageRelay.accept(.missingInput)
                return nil
        }
        
        let dates = interactor.getDatesOfConception(with: bornChildData)
        
        guard !dates.contains(where: { $0 < mother.birthdayDate || $0 < father.birthdayDate }) else {
            messageRelay.accept(.conceptionDateInvalid)
            return nil
        }
        
        if let bloodLossDate = mother.bloodLossDate, bloodLossDate < mother.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        if let bloodLossDate = father.bloodLossDate, bloodLossDate < father.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        return interactor.calculateWithBornChildByBlood(father: father, mother: mother, conceptionDates: dates)
    }
    
    func calculateByBlood() -> PredictionResult? {
        guard let father = interactor.father.value,
            let mother = interactor.mother.value,
            let date = interactor.conceptionDate.value else {
                messageRelay.accept(.missingInput)
                return nil
        }
                
        guard date >= mother.birthdayDate, date >= father.birthdayDate else {
            messageRelay.accept(.conceptionDateInvalid)
            return nil
        }
        
        if let bloodLossDate = mother.bloodLossDate, bloodLossDate < mother.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        if let bloodLossDate = father.bloodLossDate, bloodLossDate < father.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        return interactor.calculateByBlood(father: father, mother: mother, conceptionDate: date)
    }
    
    // MARK: - Calculate by Freyman Dobrotin methods
    
    func calculateByFreymanDobrotin() -> PredictionResult? {
        guard let father = interactor.father.value,
            let mother = interactor.mother.value,
            let date = interactor.conceptionDate.value else {
                messageRelay.accept(.missingInput)
                return nil
        }
        
        guard date >= mother.birthdayDate, date >= father.birthdayDate else {
            messageRelay.accept(.conceptionDateInvalid)
            return nil
        }
        
        if let bloodLossDate = mother.bloodLossDate, bloodLossDate < mother.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        if let bloodLossDate = father.bloodLossDate, bloodLossDate < father.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        return interactor.calculateByFreymanDobrotin(father: father, mother: mother, conceptionDate: date)
    }
    
    func calculateWithBornChildByFreymanDobrotin() -> PredictionResult? {
        guard let father = interactor.father.value,
            let mother = interactor.mother.value,
            let bornChildData = interactor.bornChild.value else {
                messageRelay.accept(.missingInput)
                return nil
        }
        
        let dates = interactor.getDatesOfConception(with: bornChildData)
                
        guard !dates.contains(where: { $0 < mother.birthdayDate || $0 < father.birthdayDate }) else {
            messageRelay.accept(.conceptionDateInvalid)
            return nil
        }
        
        if let bloodLossDate = mother.bloodLossDate, bloodLossDate < mother.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        if let bloodLossDate = father.bloodLossDate, bloodLossDate < father.birthdayDate {
            messageRelay.accept(.bloodLossDateInvalid)
            return nil
        }
        
        return interactor.calculateWithBornChildByFreymanDobrotin(father: father, mother: mother, conceptionDates: dates)
    }
    
    func checkGender(with result: PredictionResult?) -> PredictionResult? {
        guard let gender = result?.gender else { return nil }
        
        guard gender == .unknown else { return result }
        messageRelay.accept(.unknownGender)
        return nil
    }
}

// MARK: - Parent configuration

private extension GenderPredictionPresenter {
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
