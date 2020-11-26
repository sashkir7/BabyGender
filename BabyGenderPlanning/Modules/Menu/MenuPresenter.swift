//
//  MenuPresenter.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift
import RxDataSources

protocol MenuPresenterProtocol {
    func buildOutput(with input: MenuPresenter.Input) -> MenuPresenter.Output
}

final class MenuPresenter: Stepper {
    var steps = PublishRelay<Step>()

    private let interactor: MenuInteractor
    private let disposeBag = DisposeBag()

    init(_ interactor: MenuInteractor) {
        self.interactor = interactor
    }
}

extension MenuPresenter: IsPresenter, MenuPresenterProtocol {
    struct Input {
        var selectedBlock: Observable<MenuRow>
    }

    struct Output {
        var dataSource: Driver<[SectionModel<String, MenuRow>]>
    }

    func bindInput(_ input: MenuPresenter.Input) {
        input.selectedBlock
            .withLatestFrom(
                interactor.isSubscriptionActive, resultSelector: { ($0, $1) })
            .map { row, isSubscriptionActive -> RouteStep in
                guard row.isPremiumFeature else { return row.step }
                return isSubscriptionActive ? row.step : .premium(fromMenu: true)
            }
            .subscribe(onNext: { [weak self] step in
                self?.steps.accept(step)
                Menu.toggle()
            })
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: MenuPresenter.Input) -> MenuPresenter.Output {
        let dataSource = Driver.just(interactor.rows)
            .map { [SectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])

        return Output(dataSource: dataSource)
    }
}
