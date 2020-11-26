//
//  AboutPremiumPresenter.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift
import RxDataSources

protocol AboutPremiumPresenterProtocol {
    func buildOutput(with input: AboutPremiumPresenter.Input) -> AboutPremiumPresenter.Output
}

final class AboutPremiumPresenter: Stepper {
    var steps = PublishRelay<Step>()
        
    private let interactor: AboutPremiumInteractor
    private let disposeBag = DisposeBag()
    
    private let showLoader = PublishRelay<String>()
    private let hideLoader = PublishRelay<String>()
    
    init(_ interactor: AboutPremiumInteractor) {
        self.interactor = interactor
    }
}

extension AboutPremiumPresenter: IsPresenter, AboutPremiumPresenterProtocol {
    struct Input {
        let backTrigger: Observable<Void>
        let didTapBuyButton: Observable<Void>
        let didTapRestoreButton: Observable<Void>
    }

    struct Output {
        let subscriptionExpirationDate: Driver<Date?>
        let subscriptionPeriodTypeTitle: Driver<String>
        let buyButtonTitle: Driver<String>
        let updateMenuButtonImage: Driver<UIImage?>
        let dataSource: Driver<[SectionModel<String, PremiumExampleCard>]>
        
        let showLoader: Driver<String>
        let hideLoader: Driver<String>
    }

    func bindInput(_ input: AboutPremiumPresenter.Input) {
        input.backTrigger
            .withLatestFrom(interactor.fromMenu)
            .compactMap { isMenuButton in
                guard !isMenuButton else {
                    Menu.toggle()
                    return nil
                }
                return RouteStep.pop
            }
            .bind(to: steps)
            .disposed(by: disposeBag)

        input.didTapBuyButton.map { [unowned self] in
            return ReachabilityService.shared.isInternetActive ?
                self.getSubscriptionOrTrialRouteStep() :
                RouteStep.showWarningAlert(
                    title: Localized.premium_alert_title(),
                    message: Localized.premium_alert_message())
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapRestoreButton
            .do(onNext: { [unowned self] _ in self.showLoader.accept(Localized.purchasing_reloading_subscribe()) })
            .flatMap(interactor.restorePurchases)
            .subscribe(onNext: { [unowned self] isSuccess in
                guard isSuccess else {
                    self.hideLoader.accept(Localized.purchasing_reloading_failure())
                    return
                }
                self.hideLoader.accept(Localized.purchasing_reloading_success())
            })
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: AboutPremiumPresenter.Input) -> AboutPremiumPresenter.Output {
        let subscriptionExpirationDate = interactor.activeSubscriptionExpirationDate.asDriverOnErrorJustComplete()
        let subscriptionPeriodTypeTitle = interactor.subscriptionPeriodTypeTitle.asDriverOnErrorJustComplete()
        let buyButtonTitle = interactor.buyButtonTitle.asDriverOnErrorJustComplete()
        
        let showLoader = self.showLoader.asDriver(onErrorJustReturn: "")
        let hideLoader = self.hideLoader.asDriver(onErrorJustReturn: "")
        
        let updateMenuButtonImage = interactor.fromMenu
            .asObservable()
            .map { fromMenu in return fromMenu ? Image.menu() : Image.backArrow() }
            .asDriver(onErrorJustReturn: Image.menu())
        
        let dataSource = Driver
            .just([PremiumExampleCard.advantages,
                   PremiumExampleCard.genderPlanning,
                   PremiumExampleCard.savingResults])
            .map { [SectionModel(model: "", items: $0)] }
        
        return Output(subscriptionExpirationDate: subscriptionExpirationDate,
                      subscriptionPeriodTypeTitle: subscriptionPeriodTypeTitle,
                      buyButtonTitle: buyButtonTitle,
                      updateMenuButtonImage: updateMenuButtonImage,
                      dataSource: dataSource,
                      showLoader: showLoader,
                      hideLoader: hideLoader)
    }

    func getSubscriptionOrTrialRouteStep() -> RouteStep {
        return (PremiumService.shared.isAllowTrialPeriod.value
            || PremiumService.shared.isUsedTrialPeriod.value) ?
                RouteStep.trial :
                RouteStep.subscriptions
    }
}
