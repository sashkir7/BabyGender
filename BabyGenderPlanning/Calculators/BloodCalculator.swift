//
//  BloodCalculator.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

class BloodCalculator: GenderCalculatorType {
    func calculateResultWithBornChild(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date]) -> (gender: Gender, dates: [Date]) {
        var maleDates = [Date]()
        var femaleDates = [Date]()
        
        conceptionDates.forEach { date in
            let gender = calculateResult(father: father, mother: mother, conceptionDate: date)
            if gender != .unknown {
                gender == .male ? maleDates.append(date) : femaleDates.append(date)
            }
        }
        
        guard !maleDates.isEmpty || !femaleDates.isEmpty else { return (.unknown, []) }
        
        return maleDates.count > femaleDates.count ?
            (.male, maleDates) :
            (.female, femaleDates)
    }
    
    func calculateResultForPlanning(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date], desiredGender: Gender) -> [Date] {
        var maleDates = [Date]()
        var femaleDates = [Date]()
        
        conceptionDates.forEach { date in
            let gender = calculateResult(father: father, mother: mother, conceptionDate: date)
            if gender != .unknown {
                gender == .male ? maleDates.append(date) : femaleDates.append(date)
            }
        }
        
        return desiredGender == .male ?
            maleDates :
            femaleDates
    }
    
    func calculateResult(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> Gender {
        var gender: Gender = .male
        
        gender = calculateWithBloodLoss(father: father, mother: mother, conceptionDate: conceptionDate)

        if mother.bloodGroup?.rhesusFactor == .negative, gender != .unknown {
            gender = gender == .male ? .female : .male
        }

        guard gender == .unknown, let fatherGroup = father.bloodGroup, let motherGroup = mother.bloodGroup else {
            return gender
        }

        return calculateWithBloodGroup(fatherGroup: fatherGroup, motherGroup: motherGroup)
    }
}

// MARK: - Helper methods

extension BloodCalculator {
    private func calculateByNewestBlood(fatherDate: Date, motherDate: Date, conceptionDate: Date) -> Gender {
        var lastFatherBloodRenewalDate = fatherDate
        while lastFatherBloodRenewalDate.getNextBloodRenewalDate(renewalCycle: kMaleBloodRenewalPeriod) < conceptionDate {
            lastFatherBloodRenewalDate = lastFatherBloodRenewalDate.getNextBloodRenewalDate(renewalCycle: kMaleBloodRenewalPeriod)
        }
        
        var lastMotherBloodRenewalDate = motherDate
        
        while lastMotherBloodRenewalDate.getNextBloodRenewalDate(renewalCycle: kFemaleBloodRenewalPeriod) < conceptionDate {
            lastMotherBloodRenewalDate = lastMotherBloodRenewalDate.getNextBloodRenewalDate(renewalCycle: kFemaleBloodRenewalPeriod)
        }
        
        guard !lastFatherBloodRenewalDate.isEqual(to: lastMotherBloodRenewalDate) else { return .unknown }

        return lastFatherBloodRenewalDate > lastMotherBloodRenewalDate ? .male : .female
    }

    private func calculateWithBloodLoss(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> Gender {
        let fatherDate = getParentDate(father, conceptionDate)
        let motherDate = getParentDate(mother, conceptionDate)

        return calculateByNewestBlood(fatherDate: fatherDate, motherDate: motherDate, conceptionDate: conceptionDate)

    }

    private func calculateWithBloodGroup(fatherGroup: BloodGroupInfo, motherGroup: BloodGroupInfo) -> Gender {
        var motherGroup = motherGroup
        if motherGroup.level == 0 {
            motherGroup.level = 1
        }

        precondition(fatherGroup.level <= 4 && fatherGroup.level >= 1)
        precondition(motherGroup.level <= 4 && motherGroup.level >= 1)

        switch (motherGroup.level, fatherGroup.level) {
        case (1, 1),
             (1, 3),
             (2, 2),
             (2, 4),
             (3, 1),
             (4, 2):
            return .female
        default:
            return .male
        }
    }

    private func getParentDate(_ parent: ParentInfo, _ conceptionDate: Date) -> Date {
        guard let bloodLossDate = parent.bloodLossDate, bloodLossDate < conceptionDate else { return parent.birthdayDate }
        return bloodLossDate
    }
}
