//
//  AAAPresenter.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 01.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol AboutAppPresenterProtocol {
    func buildOutput(with input: AboutAppPresenter.Input) -> AboutAppPresenter.Output
}

final class AboutAppPresenter: Stepper {
    var steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()

    private let messageRelay = PublishRelay<ToastMessage>()
}

extension AboutAppPresenter: IsPresenter, AboutAppPresenterProtocol {
    struct Input {
        let acceptButtonTap: Observable<Void>
        let backButtonTap: Observable<Void>
    }

    struct Output {
        let message: Driver<ToastMessage>
    }

    func bindInput(_ input: AboutAppPresenter.Input) {
        guard !AcceptPolicyService.isAcceptPolicy else { return }

        input.acceptButtonTap
            .do(onNext: { _ in
                AcceptPolicyService.isAcceptPolicy = true
            })
            .map { RouteStep.start }
            .bind(to: steps)
            .disposed(by: disposeBag)

        input.backButtonTap
            .map { ToastMessage.acceptPolicy }
            .bind(to: messageRelay)
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: AboutAppPresenter.Input) -> AboutAppPresenter.Output {
        return Output(
            message: messageRelay.asDriverOnErrorJustComplete()
        )
    }
}
