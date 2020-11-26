//
//  ContainerPresenter.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 28.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

protocol ContainerPresenterProtocol {
    func buildInput(with input: ContainerPresenter.Input)
}

final class ContainerPresenter: Stepper {
    var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
}

extension ContainerPresenter: ContainerPresenterProtocol {
    struct Input {
        var newStep: Observable<RouteStep>
        var dismiss: Observable<Void>
    }
    
    func buildInput(with input: ContainerPresenter.Input) {
        let newStep = input.newStep
        let dismissStep = input.dismiss.map { RouteStep.dismiss }
        
        // swiftlint:disable array_init
        
        Observable.merge(newStep, dismissStep)
            .map { $0 }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
}
