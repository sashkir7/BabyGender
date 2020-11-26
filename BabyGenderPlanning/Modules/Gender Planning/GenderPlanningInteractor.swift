//
//  GenderPlanningInteractor.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 29.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa

final class GenderPlanningInteractor {
    let father = BehaviorRelay<ParentInfo?>(value: nil)
    let mother = BehaviorRelay<ParentInfo?>(value: nil)
    
    let loadedFather = BehaviorRelay<ParentInfo?>(value: nil)
    let loadedMother = BehaviorRelay<ParentInfo?>(value: nil)
    
    let fatherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    let motherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    
    private let disposeBag = DisposeBag()
    private let planningCalculator: PlanningCalculator
    
    let fromPredictionScreen = BehaviorRelay<Bool>(value: false)
    
    init(planningCalculator: PlanningCalculator = .init(), fromPredictionScreen: Bool) {
        self.planningCalculator = planningCalculator
        self.fromPredictionScreen.accept(fromPredictionScreen)
    }
    
    @discardableResult
    func saveCalculation(_ calculation: CalculationInfo) -> Bool {
        let motherSavedName = getMotherNameFromSavedParents(with: (calculation.motherBirthday, calculation.motherBloodGroup), method: calculation.method)
        let fatherSavedName = getFatherNameFromSavedParents(with: (calculation.fatherBirthday, calculation.fatherBloodGroup), method: calculation.method)

        var calculation = calculation
        calculation.motherName = ""
        calculation.fatherName = ""

        if calculation.method == .freymanDobroting {
            calculation.motherBloodGroup = nil
            calculation.fatherBloodGroup = nil
        }

        if let motherSavedName = motherSavedName {
            calculation.motherName = motherSavedName
        }

        if let fatherSavedName = fatherSavedName {
            calculation.fatherName = fatherSavedName
        }

        let calculationObj = calculation.realmObject

        if let oldCalculation = RealmStorage.default.objects(Calculation.self).first(where: { calculationObj.isEqualTo($0) }) {
            calculationObj.id = oldCalculation.id
        }
        
        RealmStorage.default.save([calculationObj], updatePolicy: .all)
        return true
    }
    
    // MARK: - Calculate by Freyman Dobrotin
    
    func calculateByFreymanDobrotin(father: ParentInfo, mother: ParentInfo, periodInMonth: Int, desiredGender: Gender) -> CalculationInfo? {
        return planningCalculator
            .calculateByFreymanDobrotin(father: father, mother: mother, periodInMonth: periodInMonth, desiredGender: desiredGender)
    }
    
    // MARK: - Calculate by blood
    
    func calculateByBlood(father: ParentInfo, mother: ParentInfo, periodInMonth: Int, desiredGender: Gender) -> CalculationInfo? {
        return planningCalculator.calculateByBlood(father: father, mother: mother, periodInMonth: periodInMonth, desiredGender: desiredGender)
    }
}

private extension GenderPlanningInteractor {
    func getMotherNameFromSavedParents(with mother: (birthdayDate: Date, bloodGroup: BloodGroupInfo?), method: CalculationMethod) -> String? {
        var returnMother: Parent?
        let savedMothers = RealmStorage.default.objects(Parent.self)
            .filter { $0.gender == .female }

        if method == .freymanDobroting {
            returnMother = savedMothers.first(where: {
                mother.birthdayDate.day == $0.birthdayDate.day &&
                mother.birthdayDate.month == $0.birthdayDate.month &&
                mother.birthdayDate.year == $0.birthdayDate.year
            })
        } else {
            returnMother = savedMothers.first(where: {
                mother.birthdayDate.day == $0.birthdayDate.day &&
                mother.birthdayDate.month == $0.birthdayDate.month &&
                mother.birthdayDate.year == $0.birthdayDate.year &&
                mother.bloodGroup?.level == $0.bloodGroup?.level &&
                mother.bloodGroup?.rhesusFactor == $0.bloodGroup?.rhesusFactor
            })
        }

        return returnMother?.name
    }

    func getFatherNameFromSavedParents(with father: (birthdayDate: Date, bloodGroup: BloodGroupInfo?), method: CalculationMethod) -> String? {
        var returnFather: Parent?
        let savedFathers = RealmStorage.default.objects(Parent.self)
            .filter { $0.gender == .male }

        if method == .freymanDobroting {
            returnFather = savedFathers.first(where: {
                father.birthdayDate.day == $0.birthdayDate.day &&
                father.birthdayDate.month == $0.birthdayDate.month &&
                father.birthdayDate.year == $0.birthdayDate.year
            })
        } else {
            returnFather = savedFathers.first(where: {
                father.birthdayDate.day == $0.birthdayDate.day &&
                father.birthdayDate.month == $0.birthdayDate.month &&
                father.birthdayDate.year == $0.birthdayDate.year &&
                father.bloodGroup?.level == $0.bloodGroup?.level &&
                father.bloodGroup?.rhesusFactor == $0.bloodGroup?.rhesusFactor
            })
        }

        return returnFather?.name
    }
}
