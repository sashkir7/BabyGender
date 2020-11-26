//
//  PredictionResult.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 16.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

enum PredictionResult {
    case defaultCalculation(gender: Gender)
    case checkOnBornChildren(gender: Gender, dates: [Date])
    
    var gender: Gender {
        switch self {
        case let .defaultCalculation(gender):
            return gender
        case let .checkOnBornChildren(gender, _):
            return gender
        }
    }
}
