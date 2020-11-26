//
//  GenderPredictionInteractor.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import Purchases

final class GenderPredictionInteractor {
    var isSubscriptionActive = BehaviorRelay<Bool>(value: false)
    
    let father = BehaviorRelay<ParentInfo?>(value: nil)
    let mother = BehaviorRelay<ParentInfo?>(value: nil)
    let bornChild = BehaviorRelay<BornChildData?>(value: nil)
    let conceptionDate = BehaviorRelay<Date?>(value: nil)
    
    let loadedFather = BehaviorRelay<ParentInfo?>(value: nil)
    let loadedMother = BehaviorRelay<ParentInfo?>(value: nil)
    
    let fatherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    let motherBloodGroup = BehaviorRelay<BloodGroupInfo?>(value: nil)
    
    let clearAllData = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    private let conceptionDateCalculator: ConceptionDateCalculator
    private let freymanDobrotinCalculator: FreymanDobrotinCalculator
    private let bloodCalculator: BloodCalculator
    
    init(conceptionDateCalculator: ConceptionDateCalculator = .init(),
         freymanDobrotinCalculator: FreymanDobrotinCalculator = .init(),
         bloodCalculator: BloodCalculator = .init()) {
        self.conceptionDateCalculator = conceptionDateCalculator
        self.freymanDobrotinCalculator = freymanDobrotinCalculator
        self.bloodCalculator = bloodCalculator
        
        PremiumService.shared.purchaserInfo.map { !($0?.entitlements.active.isEmpty ?? false) }.bind(to: isSubscriptionActive).disposed(by: disposeBag)
    }
    
    // MARK: - Set nil values
    
    func setNilValues() {
        father.accept(nil)
        mother.accept(nil)
        bornChild.accept(nil)
        conceptionDate.accept(nil)
        fatherBloodGroup.accept(nil)
        motherBloodGroup.accept(nil)
    }
    
    // MARK: - Get conception dates methods
    
    func getDatesOfConceptionText(with data: BornChildData?) -> String? {
        guard let data = data else { return nil }
        return conceptionDateCalculator.getDatesOfConceptionText(with: data)
    }
    
    func getDatesOfConception(with data: BornChildData) -> [Date] {
        return conceptionDateCalculator.getDatesOfConception(with: data)
    }
    
    // MARK: - Calculate by Freyman Dobrotin methods
    
    func calculateWithBornChildByFreymanDobrotin(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date]) -> PredictionResult {
        let result = freymanDobrotinCalculator.calculateResultWithBornChild(father: father, mother: mother, conceptionDates: conceptionDates)
        
        return .checkOnBornChildren(gender: result.gender, dates: result.dates)
    }
    
    func calculateByFreymanDobrotin(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> PredictionResult {
        let result = freymanDobrotinCalculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        
        return .defaultCalculation(gender: result)
    }
    
    // MARK: - Calculate by blood methods
    
    func calculateWithBornChildByBlood(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date]) -> PredictionResult {
        let result = bloodCalculator.calculateResultWithBornChild(father: father, mother: mother, conceptionDates: conceptionDates)
        
        return .checkOnBornChildren(gender: result.gender, dates: result.dates)
    }
    
    func calculateByBlood(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> PredictionResult {
        let result = bloodCalculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        
        return .defaultCalculation(gender: result)
    }
}
