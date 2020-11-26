//
//  DetailSavedResultPresenter.swift
//  BabyGenderPlanning
//
//  Created by Alx Krw on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol DetailSavedResultPresenterProtocol {
    func buildOutput(with input: DetailSavedResultPresenter.Input) -> DetailSavedResultPresenter.Output
}

final class DetailSavedResultPresenter: Stepper {
    var steps = PublishRelay<Step>()

    private let interactor: DetailSavedResultInteractor
    private let disposeBag = DisposeBag()

    init(_ interactor: DetailSavedResultInteractor) {
        self.interactor = interactor
    }
}

extension DetailSavedResultPresenter: IsPresenter, DetailSavedResultPresenterProtocol {
    struct Input {
        let backTrigger: Observable<Void>
        let deleteTrigger: Observable<Void>
        let recomendationTrigger: Observable<Void>
    }

    struct Output {
        let calculationInfo: Driver<CalculationInfo>
    }

    func bindInput(_ input: DetailSavedResultPresenter.Input) {
        input.backTrigger
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.recomendationTrigger
            .map { [unowned self] in
                RouteStep.recommendations(gender: self.interactor.calculationInfo.value?.gender ?? .male)
            }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.deleteTrigger.subscribe(onNext: { [unowned self] in
            self.deleteCalculation()
            })
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: DetailSavedResultPresenter.Input) -> DetailSavedResultPresenter.Output {
        let calculationInfo = interactor.calculationInfo.compactMap { $0 }.asDriverOnErrorJustComplete()

        return Output(calculationInfo: calculationInfo)
    }
    
    func deleteCalculation() {
        let step = RouteStep.deleteCalculation { [weak self] _ in
            self?.interactor.deleteCalculation()
            
            let backStep = RouteStep.pop
            self?.steps.accept(backStep)
        }
        steps.accept(step)
    }
}
