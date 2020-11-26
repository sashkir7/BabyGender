//
//  Parent.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation
import RealmSwift

class Parent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var birthdayDate: Date = Date()
    @objc dynamic var gender: Gender = .unknown
    @objc dynamic var bloodGroup: BloodGroup?
    @objc dynamic var bloodLossDate: Date?

    override class func primaryKey() -> String? {
        return #keyPath(Parent.id)
    }

    convenience init(id: String, name: String, birthdayDate: Date, gender: Gender, bloodGroup: BloodGroup?, bloodLossDate: Date?) {
        self.init()
        self.id = id
        self.name = name
        self.birthdayDate = birthdayDate
        self.gender = gender
        self.bloodGroup = bloodGroup
        self.bloodLossDate = bloodLossDate
    }
}
