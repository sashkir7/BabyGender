//
//  ReusableView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 22.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

enum ReusableView {
    case aboutBloodLoss(gender: Gender)
    case bloodGroupPicker(gender: Gender, bloodGroup: BloodGroupInfo? = nil)
    case parentPicker(gender: Gender)
    case insertableTextView(text: String, title: String)
    
    var insertable: InsertableView {
        switch self {
        case let .aboutBloodLoss(gender):
            return AboutBloodLossView(gender: gender)
        case let .bloodGroupPicker(gender, bloodGroup):
            return BloodGroupPickerView(gender: gender, bloodGroup: bloodGroup)
        case let .parentPicker(gender):
            return ParentPickerView(gender: gender)
        case let .insertableTextView(text, title):
            return InsertableTextView(text: text, title: title)
        }
    }
}
