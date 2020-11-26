//
//  BloodGroupInfo.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

struct BloodGroupInfo {
    var id: String
    var level: Int
    var rhesusFactor: RhesusFactor

    var realmObject: BloodGroup {
        return BloodGroup(id: id, level: level, rhesusFactor: rhesusFactor)
    }

    init?(realmObject: BloodGroup?) {
        guard let realmObject = realmObject else { return nil }
        
        self.id = realmObject.id
        self.level = realmObject.level
        self.rhesusFactor = realmObject.rhesusFactor
    }

    init(id: String, level: Int, rhesusFactor: RhesusFactor) {
        self.id = id
        self.level = level
        self.rhesusFactor = rhesusFactor
    }

    var levelToRomanFormat: String {
        guard 1...4 ~= level else { return "" }
        guard level != 4 else { return "IV" }

        return (1...level)
            .map { _ in "I" }
            .reduce("", +)
    }

    var rhesusFactorToString: String {
        return rhesusFactor == .positive ? "+" : "-"
    }

    var stringFormatted: String {
        return level == 0 ? "" : "\(levelToRomanFormat) (\(rhesusFactorToString))"
    }
}
