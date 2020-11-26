//
//  StyledGenderButton.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 04.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StyledGenderButton: UIButton {
    var gender: Gender {
        didSet {
            switch gender {
            case .female:
                setTitle(Localized.femaleGender(), for: .normal)
            case .male:
                setTitle(Localized.maleGender(), for: .normal)
            default:
                setTitle("", for: .normal)
            }
        }
    }
    
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(gender: Gender = .female) {
        self.gender = gender
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = Constants.styledViewCornerRadius
        
        setTitleColor(.barossa, for: .normal)

        titleLabel?.font = UIFont.generalTextFont
        
        rx.tap
            .map { [weak self] in
                self?.gender == .female ? .male : .female
            }
            .bind(to: rx.gender)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: StyledGenderButton {
    var gender: ControlProperty<Gender> {
        return value
    }

    /// Reactive wrapper for `date` property.
    var value: ControlProperty<Gender> {
        return base.rx.controlProperty(editingEvents: .touchUpInside,
                                       getter: { button in
                                           button.gender
                                       },
                                       setter: { button, gender in
                                           button.gender = gender
                                       })
    }
}
