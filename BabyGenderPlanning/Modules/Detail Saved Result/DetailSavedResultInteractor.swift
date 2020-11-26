//
//  DetailSavedResultInteractor.swift
//  BabyGenderPlanning
//
//  Created by Alx Krw on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa

final class DetailSavedResultInteractor {
    
    let calculationInfo = BehaviorRelay<CalculationInfo?>(value: nil)
    
    init(withCalculationInfo info: CalculationInfo) {
        self.calculationInfo.accept(info)
    }
    
    func deleteCalculation() {
        guard let calculationInfo = calculationInfo.value,
            let calculation = RealmStorage.default.object(Calculation.self, forPrimaryKey: calculationInfo.id) else {
                return
        }
        RealmStorage.default.delete(calculation)
    }
}
