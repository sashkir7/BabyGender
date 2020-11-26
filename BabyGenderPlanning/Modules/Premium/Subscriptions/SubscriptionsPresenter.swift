//
//  SubscriptionsPresenter.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol SubscriptionsPresenterProtocol {
    func buildOutput(with input: SubscriptionsPresenter.Input) -> SubscriptionsPresenter.Output
}

final class SubscriptionsPresenter: Stepper {
    private let interactor: SubscriptionsInteractor
    
    var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
    
    private let showLoader = PublishRelay<String>()
    private let hideLoader = PublishRelay<String>()
    private let shouldPop = PublishRelay<Void>()
    
    init(_ interactor: SubscriptionsInteractor) {
        self.interactor = interactor
    }
}

extension SubscriptionsPresenter: IsPresenter, SubscriptionsPresenterProtocol {
    struct Input {
        let backButtonTap: Observable<Void>
        let oneMonthTap: Observable<Void>
        let threeMonthsTap: Observable<Void>
        let sixMonthsTap: Observable<Void>
        let oneYearTap: Observable<Void>
    }
    
    struct Output {
        let oneMonthButtonTitle: Driver<String?>
        let threeMonthButtonTitle: Driver<String?>
        let sixMonthButtonTitle: Driver<String?>
        let oneYearButtonTitle: Driver<String?>

        let threeMonthSaleTitle: Driver<String?>
        let sixMonthSaleTitle: Driver<String?>
        let oneYearSaleTitle: Driver<String?>

        let showLoader: Driver<String>
        let hideLoader: Driver<String>
    }
    
    func bindInput(_ input: Input) {
        input.backButtonTap
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        Observable
            .merge(input.oneMonthTap.map { 0 },
                   input.threeMonthsTap.map { 1 },
                   input.sixMonthsTap.map { 2 },
                   input.oneYearTap.map { 3 })
            .do(onNext: { [unowned self] _ in self.showLoader.accept(Localized.purchasing_subscription()) })
            .flatMap { [unowned self] index in
                self.interactor.purchaseOption(atIndex: index)
            }
            .subscribe(onNext: { [unowned self] isSuccess in
                guard isSuccess else {
                    self.hideLoader.accept(Localized.purchasing_subscription_failure())
                    return
                }
                self.hideLoader.accept(Localized.purchasing_subscription_success())
                self.shouldPop.accept(())
            })
            .disposed(by: disposeBag)
        
        shouldPop
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
        
    func configureOutput(_ input: SubscriptionsPresenter.Input) -> SubscriptionsPresenter.Output {
        let showLoader = self.showLoader.asDriver(onErrorJustReturn: "")
        let hideLoader = self.hideLoader.asDriver(onErrorJustReturn: "")

        let oneMonthButtonTitle = interactor.oneMonthButtonTitle.asObservable().asDriverOnErrorJustComplete()
        let threeMonthButtonTitle = interactor.threeMonthButtonTitle.asObservable().asDriverOnErrorJustComplete()
        let sixMonthButtonTitle = interactor.sixMonthButtonTitle.asObservable().asDriverOnErrorJustComplete()
        let oneYearButtonTitle = interactor.oneYearButtonTitle.asObservable().asDriverOnErrorJustComplete()
        let threeMonthSaleTitle = interactor.threeMonthSaleTitle.asObservable().asDriverOnErrorJustComplete()
        let sixMonthSaleTitle = interactor.sixMonthSaleTitle.asObservable().asDriverOnErrorJustComplete()
        let oneYearSaleTitle = interactor.oneYearSaleTitle.asObservable().asDriverOnErrorJustComplete()

        return Output(
            oneMonthButtonTitle: oneMonthButtonTitle,
            threeMonthButtonTitle: threeMonthButtonTitle,
            sixMonthButtonTitle: sixMonthButtonTitle,
            oneYearButtonTitle: oneYearButtonTitle,
            threeMonthSaleTitle: threeMonthSaleTitle,
            sixMonthSaleTitle: sixMonthSaleTitle,
            oneYearSaleTitle: oneYearSaleTitle,
            showLoader: showLoader,
            hideLoader: hideLoader
        )
    }
}

// MARK: - Helper methods

private extension SubscriptionsPresenter {
}
