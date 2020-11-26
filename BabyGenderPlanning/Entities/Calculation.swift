//
//  Calculation.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 30.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Realm
import RealmSwift

class Calculation: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var method: CalculationMethod = .freymanDobroting
    @objc dynamic var gender: Gender = .unknown
    @objc dynamic var calculationDate: Date = Date()
    @objc dynamic var fatherBirthday: Date = Date()
    @objc dynamic var motherBirthday: Date = Date()
    @objc dynamic var fatherBloodGroup: BloodGroup?
    @objc dynamic var motherBloodGroup: BloodGroup?
    @objc dynamic var fatherName: String?
    @objc dynamic var motherName: String?
    
    let planningResults = List<PlanningResult>()
    
    override class func primaryKey() -> String? {
        return #keyPath(Calculation.id)
    }
    
    convenience init(id: String,
                     method: CalculationMethod,
                     gender: Gender,
                     calculationDate: Date,
                     fatherBirthday: Date,
                     motherBirthday: Date,
                     fatherBloodGroup: BloodGroup?,
                     motherBloodGroup: BloodGroup?,
                     fatherName: String?,
                     motherName: String?,
                     planningResults: [PlanningResult]) {
        self.init()
        self.id = id
        self.method = method
        self.gender = gender
        self.calculationDate = calculationDate
        self.fatherBirthday = fatherBirthday
        self.motherBirthday = motherBirthday
        self.fatherBloodGroup = fatherBloodGroup
        self.motherBloodGroup = motherBloodGroup
        self.fatherName = fatherName
        self.motherName = motherName
        self.planningResults.append(objectsIn: planningResults)
    }
    
    func isEqualTo(_ calc: Calculation) -> Bool {
        var isEqual = true
        isEqual = isEqual && calc.method == method
        isEqual = isEqual && calc.gender == gender
        isEqual = isEqual && calc.calculationDate.isEqual(to: calculationDate)
        isEqual = isEqual && calc.fatherBirthday.isEqual(to: fatherBirthday)
        isEqual = isEqual && calc.motherBirthday.isEqual(to: motherBirthday)
        
        if let fatherBloodGroup = fatherBloodGroup, let calcFatherBloodGroup = calc.fatherBloodGroup {
            isEqual = isEqual && fatherBloodGroup.isEqualTo(calcFatherBloodGroup)
        } else {
            isEqual = isEqual && calc.fatherBloodGroup == fatherBloodGroup
        }
        
        if let motherBloodGroup = motherBloodGroup, let calcMotherBloodGroup = calc.motherBloodGroup {
            isEqual = isEqual && motherBloodGroup.isEqualTo(calcMotherBloodGroup)
        } else {
            isEqual = isEqual && calc.motherBloodGroup == motherBloodGroup
        }
        
        isEqual = isEqual && calc.fatherName == fatherName
        isEqual = isEqual && calc.motherName == motherName
        return isEqual
    }
}
