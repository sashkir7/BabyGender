//
//  RecommendationsPresenter.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 07.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

protocol RecommendationsPresenterProtocol {
    func buildInput(_ input: RecommendationsPresenter.Input)
}

final class RecommendationsPresenter: Stepper {
    let steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
}

extension RecommendationsPresenter: RecommendationsPresenterProtocol {
    struct Input {
        let didTapBackTrigger: Observable<Void>
        let didTapNewPlanning: Observable<Void>
    }
    
    func buildInput(_ input: RecommendationsPresenter.Input) {
        input.didTapNewPlanning
            .map { RouteStep.newPlanning }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.didTapBackTrigger
            .map { RouteStep.pop }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
}
