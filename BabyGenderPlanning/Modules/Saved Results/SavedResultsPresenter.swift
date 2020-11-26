//
//  SavedResultsPresenter.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 06.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import RxDataSources

protocol SavedResultsPresenterProtocol {
    func buildOutput(with input: SavedResultsPresenter.Input) -> SavedResultsPresenter.Output
}

final class SavedResultsPresenter: Stepper {
    
    let steps = PublishRelay<Step>()
    
    private var interactor: SavedResultsInteractor
    private let disposeBag = DisposeBag()
    
    init(_ interactor: SavedResultsInteractor) {
        self.interactor = interactor
    }
}

extension SavedResultsPresenter: IsPresenter, SavedResultsPresenterProtocol {
    struct Input {
        let deleteCalculation: Observable<CalculationInfo>
        let showAllDates: Observable<CalculationInfo>
        let recommendations: Observable<Gender>
        let didTapNewPlanning: Observable<Void>
    }

    struct Output {
        let dataSource: Driver<[SectionModel<String, CalculationInfo>]>
    }
    
    func bindInput(_ input: SavedResultsPresenter.Input) {
        input.deleteCalculation
            .subscribe(onNext: { [unowned self] in self.deleteCalculation($0) })
            .disposed(by: disposeBag)
        
        input.showAllDates
            .map { RouteStep.showAllDates(calculationInfo: $0) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.recommendations
            .map(RouteStep.recommendations)
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapNewPlanning
            .map { RouteStep.newPlanning }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: SavedResultsPresenter.Input) -> SavedResultsPresenter.Output {
        let dataSource = interactor.calculations
            .map { calculations in calculations.sorted(by: { $0.calculationDate > $1.calculationDate }) }
            .map { [SectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])

        return Output(dataSource: dataSource)
    }
    
    func deleteCalculation(_ calculation: CalculationInfo) {
        let step = RouteStep.deleteCalculation { [weak self] _ in
            self?.interactor.deleteCalculation(calculation)
        }

        steps.accept(step)
    }
}
