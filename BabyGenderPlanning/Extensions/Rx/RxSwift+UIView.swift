//
//  RxSwift+UIView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 05.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIView {
    var endEditing: Binder<Void> {
        return Binder(base) { view, _ in
            _ = view.endEditing(false)
        }
    }
    
    var showBorder: Binder<Bool> {
        return Binder(base) { view, result in
            let borderColor = UIColor.mulberry.cgColor
            let borderWidth: CGFloat = result ? 3 : 0
            
            view.layer.borderColor = borderColor
            view.layer.borderWidth = borderWidth
        }
    }
    
    var toastMessage: Binder<ToastMessage> {
        return Binder(base) { view, toast in
            view.showToast(with: toast.message)
        }
    }
}
