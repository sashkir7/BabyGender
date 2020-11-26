//
//  ParentsListPresenter.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift
import RxDataSources

protocol ParentsListPresenterProtocol {
    func buildOutput(with input: ParentsListPresenter.Input) -> ParentsListPresenter.Output
}

final class ParentsListPresenter: Stepper {
    var steps = PublishRelay<Step>()
    
    private let interactor: ParentsListInteractor
    private let disposeBag = DisposeBag()

    init(_ interactor: ParentsListInteractor) {
        self.interactor = interactor
    }
}

extension ParentsListPresenter: IsPresenter, ParentsListPresenterProtocol {
    struct Input {
        let addNewParent: Observable<Void>
        let editParent: Observable<ParentInfo>
        let deleteParent: Observable<ParentInfo>
    }

    struct Output {
        var dataSource: Driver<[SectionModel<String, ParentInfo>]>
    }

    func bindInput(_ input: ParentsListPresenter.Input) {
        input.addNewParent
            .map { RouteStep.updateParent(parent: nil) }
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.editParent
            .map(RouteStep.updateParent)
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        input.deleteParent
            .subscribe(onNext: { [unowned self] in self.deleteParent($0) })
            .disposed(by: disposeBag)
    }

    func configureOutput(_ input: ParentsListPresenter.Input) -> ParentsListPresenter.Output {
        let dataSource = interactor.parents
            .map { arr -> [[ParentInfo]] in
                var sections = [[ParentInfo]]()

                let females = arr.filter { $0.gender == .female }
                let males = arr.filter { $0.gender == .male }

                if !females.isEmpty { sections.append(females) }
                if !males.isEmpty { sections.append(males) }

                return sections
            }
            .map { $0.map { SectionModel(model: "", items: $0) } }
            .asDriver(onErrorJustReturn: [])

        return Output(dataSource: dataSource)
    }
    
    func deleteParent(_ parent: ParentInfo) {
        let step = RouteStep.deleteParent { [weak self] _ in
            self?.interactor.deleteParent(parent)
        }

        steps.accept(step)
    }
}
