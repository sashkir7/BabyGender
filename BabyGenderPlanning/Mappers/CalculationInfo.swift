//
//  CalculationInfo.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 30.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

struct CalculationInfo {
    var id: String
    var method: CalculationMethod
    var gender: Gender
    var calculationDate: Date
    var fatherBirthday: Date
    var motherBirthday: Date
    var fatherBloodGroup: BloodGroupInfo?
    var motherBloodGroup: BloodGroupInfo?
    var fatherName: String?
    var motherName: String?
    var planningResults: [PlanningResultInfo]

    var realmObject: Calculation {
        let planningResult = self.planningResults.map { $0.realmObject }
        
        return Calculation(id: id,
                           method: method,
                           gender: gender,
                           calculationDate: calculationDate,
                           fatherBirthday: fatherBirthday,
                           motherBirthday: motherBirthday,
                           fatherBloodGroup: fatherBloodGroup?.realmObject,
                           motherBloodGroup: motherBloodGroup?.realmObject,
                           fatherName: fatherName,
                           motherName: motherName,
                           planningResults: planningResult)
    }

    init(realmObject: Calculation) {
        self.id = realmObject.id
        self.method = realmObject.method
        self.gender = realmObject.gender
        self.calculationDate = realmObject.calculationDate
        self.fatherBirthday = realmObject.fatherBirthday
        self.motherBirthday = realmObject.motherBirthday
        self.fatherBloodGroup = BloodGroupInfo(realmObject: realmObject.fatherBloodGroup)
        self.motherBloodGroup = BloodGroupInfo(realmObject: realmObject.motherBloodGroup)
        self.fatherName = realmObject.fatherName
        self.motherName = realmObject.motherName
        self.planningResults = realmObject.planningResults.map { PlanningResultInfo(realmObject: $0) }
    }

    init(id: String,
         method: CalculationMethod,
         gender: Gender,
         calculationDate: Date,
         father: ParentInfo,
         mother: ParentInfo,
         planningResults: [PlanningResultInfo]) {
        self.id = id
        self.method = method
        self.gender = gender
        self.calculationDate = calculationDate
        self.fatherBirthday = father.birthdayDate
        self.motherBirthday = mother.birthdayDate
        self.fatherBloodGroup = father.bloodGroup
        self.motherBloodGroup = mother.bloodGroup
        self.fatherName = father.name
        self.motherName = mother.name
        self.planningResults = planningResults
    }
    
    var conceptionDatesStrings: NSAttributedString? {
        guard !planningResults.isEmpty else { return nil }
        
        let datesStrings = NSMutableAttributedString()
        let newLine = NSAttributedString(string: "\n\n")
        
        let singleMonthStrings = planningResults.compactMap { $0.conceptionDatesString }
        
        var index = 0
        
        singleMonthStrings.forEach { monthString in
            datesStrings.append(monthString)
            index += 1
            if index < singleMonthStrings.count {
                datesStrings.append(newLine)
            }
        }
        
        return datesStrings
    }
    
    var conceptionPeriodString: String? {
        guard !planningResults.isEmpty,
            let firstResult = planningResults.first,
            let lastResult = planningResults.last,
            !lastResult.days.isEmpty,
            !firstResult.days.isEmpty else { return nil }
        
        var firstDate = String(format: "%02d/%02d",
                               firstResult.days.first ?? 1,
                               firstResult.month.rawValue + 1)
        
        var lastDate = String(format: "%02d/%02d",
                              lastResult.days.last ?? 1,
                              lastResult.month.rawValue + 1)
        
        guard firstResult.year == lastResult.year else {
            firstDate += "/" + String(format: "%02d", firstResult.year % 100)
            lastDate += "/" + String(format: "%02d", lastResult.year % 100)
            
            return "\(firstDate) - \(lastDate)"
        }
        
        return "\(firstDate) - \(lastDate)"
    }
    
    var getFatherName: String? {
        guard fatherName?.isEmpty ?? true else {
            return fatherName
        }
        let birthDayString = fatherBirthday.format(dateFormat: .ddMMYYYY)
        guard let bloodGroup = fatherBloodGroup else {
            return birthDayString
        }
        return birthDayString + "\n       " + bloodGroup.stringFormatted
    }
    
    var getMotherName: String? {
        guard motherName?.isEmpty ?? true else {
            return motherName
        }
        let birthDayString = motherBirthday.format(dateFormat: .ddMMYYYY)
        guard let bloodGroup = motherBloodGroup else {
            return birthDayString
        }

        return bloodGroup.level == 0 ?
            birthDayString + "\n       " + "(\(bloodGroup.rhesusFactorToString))" :
            birthDayString + "\n       " + bloodGroup.stringFormatted
    }
}
