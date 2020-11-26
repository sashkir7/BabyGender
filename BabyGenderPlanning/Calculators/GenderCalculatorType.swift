//
//  GenderCalculatorType.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

let kMaleBloodRenewalPeriod = 4
let kFemaleBloodRenewalPeriod = 3

protocol GenderCalculatorType {
    func calculateResult(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> Gender
}
