//
//  BackwardPassable.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 17.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

protocol Receiver {}

protocol BackwardPassable {
    var receiver: Receiver { get }
    
    func receive(_ data: ReceivableType)
    func passParent(_ parent: ParentInfo)
    func passBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender)
        
    func clearData()
}

extension BackwardPassable {
    func receive(_ data: ReceivableType) {}
    func passParent(_ parent: ParentInfo) {}
    func passBloodGroup(_ bloodGroup: BloodGroupInfo, for gender: Gender) {}
    
    func clearData() {}
}
