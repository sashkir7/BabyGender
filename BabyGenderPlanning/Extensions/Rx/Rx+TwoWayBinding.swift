//
//  Rx+TwoWayBinding.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 07.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxCocoa
import RxSwift

infix operator <->

@discardableResult
func <-> <T>(variable: BehaviorRelay<T>, property: ControlProperty<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)

    let propertyToVariable = property
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
        )

    return Disposables.create(variableToProperty, propertyToVariable)
}
