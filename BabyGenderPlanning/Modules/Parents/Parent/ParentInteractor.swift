//
//  ParentInteractor.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class ParentInteractor {
    let id: String
    let name = BehaviorRelay<String?>(value: nil)
    let gender = BehaviorRelay<Gender>(value: .female)
    let birthdayDate = BehaviorRelay<Date?>(value: nil)
    let bloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    let bloodLossDate = BehaviorRelay<Date?>(value: nil)
    
    let initialParentInfo = BehaviorRelay<ParentInfo?>(value: nil)
    
    init(withParentInfo parent: ParentInfo?) {
        self.id = parent?.id ?? randomUUID
        self.name.accept(parent?.name ?? "")
        self.gender.accept(parent?.gender ?? Gender.female)
        self.birthdayDate.accept(parent?.birthdayDate)
        self.bloodGroup.accept(parent?.bloodGroup)
        self.bloodLossDate.accept(parent?.bloodLossDate)
        self.initialParentInfo.accept(parent)
    }
    
    @discardableResult
    func saveParent(_ parentInfo: ParentInfo) -> Bool {
        let parent = parentInfo.realmObject
        
        RealmStorage.default.save([parent], updatePolicy: .all)
        return true
    }
}
