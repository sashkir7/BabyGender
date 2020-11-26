//
//  PlanningResult.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 30.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RealmSwift

class PlanningResult: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var month: Month = .unknown
    @objc dynamic var year: Int = 0
    let days = List<Int>()
    
    override class func primaryKey() -> String? {
        return #keyPath(PlanningResult.id)
    }
    
    convenience init(id: String, month: Month, year: Int, days: [Int]) {
        self.init()
        self.id = id
        self.month = month
        self.year = year
        self.days.append(objectsIn: days)
    }
}
