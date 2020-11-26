//
//  CalculationMethod.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RealmSwift

@objc enum CalculationMethod: Int, RealmEnum {
    case freymanDobroting
    case bloodRenewal
}
