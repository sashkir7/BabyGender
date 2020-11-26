//
//  RxSwift+UIScrollView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 18.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UIScrollView {
    var scrollToBottom: Binder<Void> {
        return Binder(base) { scrollView, _ in
            let contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
}
