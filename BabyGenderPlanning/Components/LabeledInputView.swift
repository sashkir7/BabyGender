//
//  LabeledInputView.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 01.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout

class LabeledInputView: UIView {

    // MARK: - UI Elements

    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = .generalTextFont
        label.textColor = .barossa

        return label
    }()

    let customInputView: UIControl

    // MARK: - Lifecycle
    
    init(inputView: UIControl) {
        self.customInputView = inputView
        
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
}

// MARK: - Private Methods

extension LabeledInputView {
    private func setupSubviews() {
        addSubviews(label, customInputView)
    }

    private func configureFrames() {
        customInputView.pin
            .top()
            .height(44)
            .width(146)
            .right()
        
        label.pin
            .left()
            .before(of: customInputView, aligned: .center)
            .marginRight(9)
            .sizeToFit(.width)
    }
}
