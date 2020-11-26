//
//  StyledTextView.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class StyledTextView: UIView {
    
    var text: String = "" {
        didSet { textView.text = text }
    }
    
    // MARK: - UI elements
    
    private lazy var cornerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.styledViewCornerRadius
        view.layer.masksToBounds = false
        view.backgroundColor = .appWhite
        
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .barossa
        textView.font = .generalTextFont
        textView.dataDetectorTypes = .link
        textView.isEditable = false
        textView.isSelectable = true
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        
        return textView
    }()
    
    private lazy var babyImage: UIImageView = {
        let image = UIImageView(image: Image.baby())
        return image
    }()
    
    private lazy var chevronTop: UIImageView = {
        let image = UIImageView(image: Image.chevronTop())
        image.isHidden = true
        return image
    }()
    
    private lazy var chevronBottom: UIImageView = {
        let image = UIImageView(image: Image.chevronBottom())
        return image
    }()
    
    // MARK: - Lifecycle

    init(text: String) {
        super.init(frame: .zero)
        textView.text = text
        
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

private extension StyledTextView {
    func setupSubviews() {
        cornerView.addSubviews(textView, chevronTop, chevronBottom, babyImage)
        addSubviews(cornerView)
    }
    
    func configureSubviews() {
        cornerView.pin
            .top()
            .horizontally()
            .bottom()
        
        textView.pin
            .vertically(25)
            .horizontally(12)
        
        chevronTop.pin
            .top(8)
            .hCenter()
        
        chevronBottom.pin
            .bottom(8)
            .hCenter()
        
        babyImage.pin
            .bottom(46)
            .hCenter()
            .sizeToFit()
        
        setupChevronsVisibility()
    }
    
    func setupChevronsVisibility() {
        chevronBottom.isHidden = textView.contentSize.height < textView.frame.height
    }
}

// MARK: - UITextViewDelegate

extension StyledTextView: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        
        chevronTop.isHidden = y <= 0
        chevronBottom.isHidden = y >= (scrollView.contentSize.height - scrollView.frame.height)
    }
}
