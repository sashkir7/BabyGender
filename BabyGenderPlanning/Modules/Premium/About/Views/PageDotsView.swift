//
//  PageDotsView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PageDotsView: UIView {
    
    var currentPageIndex: Int = 0 {
        didSet { pageSelected(currentPageIndex) }
    }
    
    // MARK: - UI elements
    
    private lazy var firstDot = UIImageView()
    private lazy var secondDot = UIImageView()
    private lazy var thirdDot = UIImageView()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)

        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
}

// MARK: - Layout

extension PageDotsView {
    private func setupSubviews() {
        addSubviews(firstDot, secondDot, thirdDot)
    }
    
    private func configureSubviews() {
        firstDot.pin
            .size(24)
            .top()
            .left()
        
        secondDot.pin
            .size(24)
            .top()
            .after(of: firstDot)
            .marginLeft(20)
        
        thirdDot.pin
            .size(24)
            .top()
            .after(of: secondDot)
            .marginLeft(20)
    }
    
    private func pageSelected(_ index: Int) {
        let pageNumber = index + 1
        firstDot.image = pageNumber == 1 ? Image.circleFilled() : Image.circleEmpty()
        secondDot.image = pageNumber == 2 ? Image.circleFilled() : Image.circleEmpty()
        thirdDot.image = pageNumber == 3 ? Image.circleFilled() : Image.circleEmpty()
    }
}

extension Reactive where Base: PageDotsView {
    var currentPageIndex: Binder<Int> {
        return Binder(base) { view, index in
            view.currentPageIndex = index
        }
    }
}
