//
//  TrialPeriodInteractor.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 08.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import Purchases

final class TrialPeriodInteractor {
    private let disposeBag = DisposeBag()
    let isDoneSubscription = BehaviorRelay<Bool>(value: false)

    func purchaseProductWithDiscount() {
        Purchases.shared.offerings { (offerings, error) in
            guard let packages = offerings?.current?.availablePackages,
                error == nil else {
                    self.isDoneSubscription.accept(false)
                    return
                }
            let product = packages.filter { $0.product.discounts.count > 0 }[0].product

            Purchases.shared.paymentDiscount(for: product.discounts[0], product: product, completion: { (discount, error) in
                if let paymentDiscount = discount, error == nil {

                    Purchases.shared.purchaseProduct(product, discount: paymentDiscount, { (transaction, purchaserInfo, error, cancelled) in
                        guard error == nil, purchaserInfo?.entitlements.active.first?.value != nil else {
                            self.isDoneSubscription.accept(false)
                            return
                        }

                        PremiumService.shared.isAllowTrialPeriod.accept(false)
                        PremiumService.shared.getSubscriptionPeriodTypeTitle()
                        self.isDoneSubscription.accept(true)
                    })
                } else {
                    self.isDoneSubscription.accept(false)
                }
            })
        }
    }
}






