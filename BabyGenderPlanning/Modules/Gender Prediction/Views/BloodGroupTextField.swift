//
//  BloodGroupTextField.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 17.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class BloodGroupTextField: StyledTextField {
    var didTapOnBloodGroup: Observable<Void> {
        return rx.tapGesture()
            .when(.recognized)
            .mapToVoid()
    }
    
    var bloodGroup: BloodGroupInfo? {
        didSet {
            if !(bloodGroup?.stringFormatted.isEmpty ?? false) {
                text = bloodGroup?.stringFormatted
            }
        }
    }
    
    override init(placeholder: String, withToolbar: Bool = false) {
        super.init(placeholder: placeholder, withToolbar: withToolbar)
        isUserInteractionEnabled = false
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BloodGroupTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension Reactive where Base: BloodGroupTextField {
    var bloodGroup: ControlProperty<BloodGroupInfo?> {
        return value
    }

    /// Reactive wrapper for `bloodGroup` property.
    var value: ControlProperty<BloodGroupInfo?> {
        return base.rx.controlProperty(editingEvents: .touchUpInside,
                                       getter: { view in
                                        view.bloodGroup
        },
                                       setter: { view, bloodGroup in
                                        view.bloodGroup = bloodGroup
        })
    }
}
