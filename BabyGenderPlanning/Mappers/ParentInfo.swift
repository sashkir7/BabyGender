//
//  ParentInfo.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

struct ParentInfo {
    var id: String
    var name: String
    var birthdayDate: Date
    var gender: Gender
    var bloodGroup: BloodGroupInfo?
    var bloodLossDate: Date?

    var age: Int {
        return birthdayDate.currentAge
    }

    var realmObject: Parent {
        return Parent(id: id, name: name, birthdayDate: birthdayDate, gender: gender, bloodGroup: bloodGroup?.realmObject, bloodLossDate: bloodLossDate)
    }

    init(realmObject: Parent) {
        self.id = realmObject.id
        self.name = realmObject.name
        self.birthdayDate = realmObject.birthdayDate
        self.gender = realmObject.gender
        self.bloodGroup = BloodGroupInfo(realmObject: realmObject.bloodGroup)
        self.bloodLossDate = realmObject.bloodLossDate
    }

    init(id: String, name: String, gender: Gender, birthdayDate: Date, bloodGroup: BloodGroupInfo?, bloodLossDate: Date? = nil) {
        self.id = id
        self.name = name
        self.birthdayDate = birthdayDate
        self.gender = gender
        self.bloodGroup = bloodGroup
        self.bloodLossDate = bloodLossDate
    }
}

extension ParentInfo: Equatable {
    static func == (lhs: ParentInfo, rhs: ParentInfo) -> Bool {
        return lhs.name == rhs.name &&
            lhs.birthdayDate == rhs.birthdayDate &&
            lhs.gender == rhs.gender &&
            lhs.bloodGroup?.level == rhs.bloodGroup?.level &&
            lhs.bloodGroup?.rhesusFactor == rhs.bloodGroup?.rhesusFactor &&
            lhs.bloodLossDate == rhs.bloodLossDate
    }
}
