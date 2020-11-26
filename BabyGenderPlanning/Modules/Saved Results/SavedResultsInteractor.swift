//
//  SavedResultsInteractor.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class SavedResultsInteractor {
    var calculations = BehaviorRelay<[CalculationInfo]>(value: [])

    private let disposeBag = DisposeBag()

    init() {
        startObservingRealmUpdates()
    }

    func deleteCalculation(_ calculation: CalculationInfo) {
        guard let calculation = RealmStorage.default.object(Calculation.self, forPrimaryKey: calculation.id) else { return }
        RealmStorage.default.delete(calculation)
    }
}

extension SavedResultsInteractor {
    private func startObservingRealmUpdates() {
        let realmCalculations = RealmStorage.default.objects(Calculation.self)

        Observable.collection(from: realmCalculations)
            .map { $0.map(CalculationInfo.init) }
            .bind(to: calculations)
            .disposed(by: disposeBag)
    }
}
