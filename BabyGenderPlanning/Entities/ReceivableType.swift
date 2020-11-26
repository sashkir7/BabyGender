//
//  ReceivableType.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 22.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

enum ReceivableType {
    case parent(_ parent: ParentInfo)
    case bloodGroup(_ bloodGroup: BloodGroupInfo, gender: Gender)
}
