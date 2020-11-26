//
//  ParentsListInteractor.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class ParentsListInteractor {
    var parents = BehaviorRelay<[ParentInfo]>(value: [])

    private let disposeBag = DisposeBag()

    init() {
        startObservingRealmUpdates()
    }

    func deleteParent(_ parent: ParentInfo) {
        guard let parent = RealmStorage.default.object(Parent.self, forPrimaryKey: parent.id) else { return }
        RealmStorage.default.delete(parent)
    }
}

extension ParentsListInteractor {
    private func startObservingRealmUpdates() {
        let realmParents = RealmStorage.default.objects(Parent.self)

        Observable.collection(from: realmParents)
            .map { $0.map(ParentInfo.init) }
            .bind(to: parents)
            .disposed(by: disposeBag)
    }
}
