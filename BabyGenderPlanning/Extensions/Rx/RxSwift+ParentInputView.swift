//
//  RxSwift+ParentInputView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: ParentInputView {
    var selectedMethod: Binder<CalculationMethod> {
        return Binder(base) { view, method in
            view.selectedMethod = method
        }
    }
}
