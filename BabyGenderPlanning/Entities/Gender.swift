//
//  Gender.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RealmSwift

@objc enum Gender: Int, RealmEnum {
    case male
    case female
    case unknown
}
