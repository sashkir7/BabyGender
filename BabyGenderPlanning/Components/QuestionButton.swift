//
//  QuestionButton.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

final class QuestionButton: UIButton {
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 9
        
        backgroundColor = .appWhite
        
        setTitleColor(UIColor.barossa.withAlphaComponent(0.7), for: .normal)
        setTitle("?", for: .normal)
        
        titleLabel?.font = .generalTextFont
        
        applyShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func disableShadow() {
        layer.shadowOpacity = 0
    }
}

extension QuestionButton {
    private func applyShadow() {
        backgroundColor = UIColor.white
        layer.masksToBounds = false
        layer.shadowColor = UIColor.textFieldShadow.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
