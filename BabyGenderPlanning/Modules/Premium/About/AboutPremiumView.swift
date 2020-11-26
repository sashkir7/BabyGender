//
//  AboutPremiumView.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PinLayout

final class AboutPremiumView: UIView {
    typealias PremiumSection = SectionModel<String, PremiumExampleCard>

    private let presenter: AboutPremiumPresenterProtocol
    private let disposeBag = DisposeBag()
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<PremiumSection>!
    
    // MARK: - Relay
    
    private let didSelectItemAtIndex = PublishRelay<Int>()

    // MARK: - UI Elements

    private lazy var headerView: HeaderTitleView = {
        return HeaderTitleView(title: Localized.sideMenu_premium(), isBackButton: true)
    }()
    
    private lazy var currentSubscriptionView = CurrentSubscriptionView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: AboutPremiumCollectionViewCell.self)
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()

    private lazy var buyButton: UIButton = {
        let button = GradientButton(type: .custom)
        button.setTitle(Localized.buttonBuy(), for: .normal)

        return button
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        
        button.setTitleColor(.mulberry, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        
        button.setTitle(Localized.buttonRestore().uppercased(), for: .normal)
        
        return button
    }()
    
    private lazy var pageDotsView: PageDotsView = {
        let view = PageDotsView()
        view.currentPageIndex = 0
        
        return view
    }()
    
    private lazy var loadingView = LoadingView()
    
    // MARK: - Lifecycle
    
    init(_ presenter: AboutPremiumPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)

        setupSubviews()
        setupDataSource()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(colors: .pink)
        configureSubviews()
    }
}

// MARK: - UI Bindings

extension AboutPremiumView {
    private func setupBindings() {
        let input = AboutPremiumPresenter.Input(
            backTrigger: headerView.menuButton.rx.tap.asObservable(),
            didTapBuyButton: buyButton.rx.tap.asObservable(),
            didTapRestoreButton: restoreButton.rx.tap.asObservable()
        )
        
        let output = presenter.buildOutput(with: input)

        disposeBag.insert(
            output.showLoader
                .drive(onNext: { [unowned self] text in
                    self.loadingView.text = text
                    self.showHUD(self.loadingView, with: text)
                }),
            
            output.hideLoader
                .drive(onNext: { [unowned self] text in
                    self.loadingView.text = text
                    self.removeHUD(self.loadingView, withDelay: 2.0)
                }),

            output.subscriptionPeriodTypeTitle.drive(currentSubscriptionView.rx.title),
            output.updateMenuButtonImage.drive(headerView.rx.menuButtonImage),
            output.subscriptionExpirationDate.drive(currentSubscriptionView.rx.date),
            output.buyButtonTitle.drive(buyButton.rx.title()),
            output.subscriptionExpirationDate.map { return $0 != nil }.drive(restoreButton.rx.isHidden),

            output.subscriptionExpirationDate.drive(onNext: { [unowned self] _ in self.updateLayout() }),
            collectionView.rx.setDelegate(self),
            didSelectItemAtIndex.asDriver(onErrorJustReturn: 0).drive(pageDotsView.rx.currentPageIndex),
            output.dataSource.drive(collectionView.rx.items(dataSource: dataSource))
        )
    }
}

// MARK: - Layout

extension AboutPremiumView {
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems, animationStyle: .none)
    }
    
    private func setupSubviews() {
        addSubviews(headerView, currentSubscriptionView, collectionView, pageDotsView, buyButton, restoreButton)
    }
    
    private func configureSubviews() {
        headerView.pin
            .height(64)
            .top(pin.safeArea)
            .horizontally()
        
        if currentSubscriptionView.isHidden {
            restoreButton.pin
                .height(45)
                .width(275)
                .bottom(20)
                .hCenter()
            
            buyButton.pin
                .height(55)
                .width(275)
                .above(of: restoreButton)
                .marginBottom(4)
                .hCenter()
            
            pageDotsView.pin
                .height(20)
                .width(100)
                .above(of: buyButton)
                .hCenter()
                .marginBottom(25)
            
            collectionView.pin
                .below(of: headerView)
                .above(of: pageDotsView)
                .horizontally()
                .marginTop(70)
                .marginBottom(22)
        } else {
            currentSubscriptionView.pin
                .below(of: headerView)
                .width(80%)
                .height(118)
                .hCenter()
            
            buyButton.pin
                .height(55)
                .width(275)
                .bottom(26)
                .hCenter()
            
            collectionView.pin
                .below(of: currentSubscriptionView)
                .above(of: buyButton)
                .horizontally()
                .marginTop(8)
                .marginBottom(8)
            
            pageDotsView.pin
                .height(20)
                .width(100)
                .above(of: buyButton)
                .hCenter()
                .marginBottom(25)
        }
        
        addInsetsToCollectionView()
    }
    
    private func addInsetsToCollectionView() {
        let cellWidth = collectionView.frame.width * 0.8
        let sideInset = (bounds.width - cellWidth) / 2
        
        collectionView.contentInset.left = sideInset
        collectionView.contentInset.right = sideInset
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AboutPremiumView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width * 0.8
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
}

// MARK: - AboutPremiumView UIScrollViewDelegate

extension AboutPremiumView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.scrollToNearestVisibleCollectionViewCell()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            collectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        didSelectItemAtIndex.accept(indexPath.row)
    }
}

// MARK: - Data Source Configuration

extension AboutPremiumView {
    private func setupDataSource() {
        dataSource = .init(
            configureCell: configureCell
        )
    }

    private var configureCell: RxCollectionViewSectionedReloadDataSource<PremiumSection>.ConfigureCell {
        return { _, collectionView, indexPath, card in
            let cell: AboutPremiumCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(card: card)

            return cell
        }
    }
}
