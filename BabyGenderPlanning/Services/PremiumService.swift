//
//  PremiumService.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 20.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import Purchases

final class PremiumService: NSObject, PurchasesDelegate {
    static let shared = PremiumService()
    
    let purchaserInfo = BehaviorRelay<Purchases.PurchaserInfo?>(value: nil)
    let isAllowTrialPeriod = BehaviorRelay<Bool>(value: false)
    let isUsedTrialPeriod = BehaviorRelay<Bool>(value: false)
    let oneMonthPrice = BehaviorRelay<String?>(value: nil)

    override init() {
        super.init()
        Purchases.shared.delegate = self
        
        Purchases.shared.purchaserInfo { [weak self] info, _ in
            guard let self = self else { return }
            
            self.purchaserInfo.accept(info)
        }

        getTrialPeriodPermit()
        getOneMonthPrice()
    }
    
    func purchases(_ purchases: Purchases, didReceiveUpdated info: Purchases.PurchaserInfo) {
        purchaserInfo.accept(info)
    }

    func getSubscriptionPeriodTypeTitle() {
        Purchases.shared.purchaserInfo { [unowned self] (purchaserInfo, error) in
            guard let _ = purchaserInfo?.entitlements.active.first, error == nil else {
                self.isUsedTrialPeriod.accept(false)
                return
            }
            self.isUsedTrialPeriod.accept(true)
        }
    }

    private func getTrialPeriodPermit() {
        Purchases.shared.purchaserInfo { [weak self] (purchaserInfo, _) in
            if let identifiers = purchaserInfo?.allPurchasedProductIdentifiers {
                self?.isAllowTrialPeriod.accept(identifiers.count == 0 ? true : false)
            } else {
                self?.isAllowTrialPeriod.accept(false)
            }
        }
    }

    private func getOneMonthPrice() {
        Purchases.shared.offerings { [weak self] (offerings, _) in
            guard let packages = offerings?.current?.availablePackages else {
                self?.oneMonthPrice.accept(nil)
                return
            }
            let oneMonthPrice = packages.first(where: {
                    $0.packageType == .monthly
                })?
                .localizedPriceString
            self?.oneMonthPrice.accept(oneMonthPrice)
        }
    }
}
