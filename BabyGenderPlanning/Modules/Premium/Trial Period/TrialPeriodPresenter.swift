//
//  TrialPeriodPresenter.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 08.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol TrialPeriodPresenterProtocol {
    func buildOutput(with input: TrialPeriodPresenter.Input) -> TrialPeriodPresenter.Output
}

final class TrialPeriodPresenter: Stepper {
    var steps = PublishRelay<Step>()

    private let interactor: TrialPeriodInteractor
    private let disposeBag = DisposeBag()

    private let titleShowLoader = PublishRelay<String>()
    private let titleHideLoader = PublishRelay<String>()
    private let shouldPop = PublishRelay<Void>()

    init(_ interactor: TrialPeriodInteractor) {
        self.interactor = interactor
    }
}

extension TrialPeriodPresenter: IsPresenter, TrialPeriodPresenterProtocol {
    struct Input {
        let backTrigger: Observable<Void>

        let didTapTrialPeriod: Observable<Void>
        let didTapSubscribe: Observable<Void>
    }

    struct Output {
        let showLoader: Driver<String>
        let hideLoader: Driver<String>
    }

    func bindInput(_ input: TrialPeriodPresenter.Input) {

        input.backTrigger
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)

        input.didTapTrialPeriod
            .subscribe(onNext: { [unowned self] in
                self.titleShowLoader.accept(Localized.purchasing_subscription())
                self.interactor.purchaseProductWithDiscount()
            })
            .disposed(by: disposeBag)

        interactor.isDoneSubscription
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    self.titleHideLoader.accept(Localized.purchasing_subscription_success())
                    self.shouldPop.accept(())
                } else {
                    self.titleHideLoader.accept(Localized.purchasing_subscription_failure())
                }
            })
            .disposed(by: disposeBag)

        input.didTapSubscribe
            .map { RouteStep.subscriptions }
            .bind(to: steps)
            .disposed(by: disposeBag)

        shouldPop
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: TrialPeriodPresenter.Input) -> TrialPeriodPresenter.Output {
        let showLoader = self.titleShowLoader.asDriver(onErrorJustReturn: "")
        let hideLoader = self.titleHideLoader.asDriver(onErrorJustReturn: "")

        return Output(
            showLoader: showLoader,
            hideLoader: hideLoader
        )
    }
}
