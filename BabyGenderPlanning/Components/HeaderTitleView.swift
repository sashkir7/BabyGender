//
//  HeaderTitleView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 25/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import PinLayout
import RxSwift
import RxCocoa

class HeaderTitleView: UIView {
    
    var title: String {
        didSet { titleLabel.text = title }
    }
    
    // MARK: - Observables
    
    var menuButtonClicked: Observable<Void> {
        return menuButton.rx.tap.asObservable()
    }
    
    var optionsButtonClicked: Observable<Void> {
        return optionsButton.rx.tap.asObservable()
    }
    
    // MARK: - Properties

    private(set) var disposeBag = DisposeBag()
    
    // MARK: - UI Elements

    private(set) lazy var menuButton: IndentButton = {
        let button = IndentButton()
        button.setImage(Image.menu(), for: .normal)

        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = PageTitleLabel()
        label.numberOfLines = 0

        return label
    }()

    private(set) lazy var optionsButton: ImageButton = {
        return ImageButton(image: nil)
    }()

    // MARK: - Lifecycle

    init(title: String, isBackButton: Bool = false, optionsButtonImage: UIImage? = nil) {
        self.title = title
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        if isBackButton {
            menuButton.setImage(Image.backArrow(), for: .normal)
        } else {
            menuButtonClicked.subscribe(onNext: (toggleMenu))
            .disposed(by: disposeBag)
        }

        optionsButton.isHidden = optionsButtonImage == nil
        optionsButton.imageView?.contentMode = .scaleAspectFit
        optionsButton.setImage(optionsButtonImage, for: .normal)

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

extension HeaderTitleView {

    @objc private func toggleMenu() {
        Menu.toggle()
    }

    private func setupSubviews() {
        addSubviews(menuButton, titleLabel, optionsButton)
    }

    private func configureFrames() {
        menuButton.pin
            .height(18)
            .width(22)
            .top(23)
            .left(16)
        
        titleLabel.pin
            .hCenter()
            .vCenter(to: menuButton.edge.vCenter)
            .sizeToFit()
        
        optionsButton.pin
            .size(16)
            .right(16)
            .vCenter(to: menuButton.edge.vCenter)
    }
}

extension Reactive where Base: HeaderTitleView {
    var menuButtonImage: Binder<UIImage?> {
        return Binder(base) { view, menuButtonImage in
            view.menuButton.setImage(menuButtonImage, for: .normal)
        }
    }
}
