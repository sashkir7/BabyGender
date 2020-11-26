//
//  BloodGroup.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RealmSwift

class BloodGroup: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var level: Int = 1
    @objc dynamic var rhesusFactor: RhesusFactor = .positive

    override class func primaryKey() -> String? {
        return #keyPath(BloodGroup.id)
    }

    convenience init(id: String, level: Int, rhesusFactor: RhesusFactor) {
        self.init()
        self.id = id
        self.level = level
        self.rhesusFactor = rhesusFactor
    }
    
    func isEqualTo(_ group: BloodGroup) -> Bool {
        return level == group.level && rhesusFactor == group.rhesusFactor
    }
}
