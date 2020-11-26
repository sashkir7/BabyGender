//
//  CALayer+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 04.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: CALayer {
    /// Bindable sink for `hidden` property.
    var isHidden: Binder<Bool> {
        return Binder(self.base) { layer, hidden in
            layer.isHidden = hidden
        }
    }
}
