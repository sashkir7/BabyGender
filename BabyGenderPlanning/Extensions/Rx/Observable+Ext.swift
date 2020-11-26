//
//  Observable+Ext.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 01.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension ObservableType where Element == Bool {
    /// Boolean not operator
    func not() -> Observable<Bool> {
        return self.map(!)
    }
}

public extension ObservableConvertibleType where Element == Void {
    func asVoidDriver() -> RxCocoa.Driver<Self.Element> {
        return asDriver(onErrorJustReturn: ())
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { error in
            print(error)
            return .empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
