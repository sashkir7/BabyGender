//
//  AboutPremiumInteractor.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 11.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Purchases

final class AboutPremiumInteractor: NSObject {
    var activeSubscriptionExpirationDate = BehaviorRelay<Date?>(value: nil)
    let subscriptionPeriodTypeTitle = BehaviorRelay<String>(value: Localized.my_premium_title())
    let buyButtonTitle = BehaviorRelay<String>(value: Localized.buttonBuy())
    var fromMenu = BehaviorRelay<Bool>(value: true)
    
    private let disposeBag = DisposeBag()
    
    init(fromMenu: Bool) {
        super.init()
        
        self.fromMenu.accept(fromMenu)
        
        PremiumService.shared.purchaserInfo.map { info -> Date? in
            guard !(info?.entitlements.active.isEmpty ?? false) else {
                return nil
            }
            return info?.latestExpirationDate
        }
        .bind(to: activeSubscriptionExpirationDate)
        .disposed(by: disposeBag)

        PremiumService.shared.isUsedTrialPeriod
            .map { $0 ?
                Localized.my_trial_title() :
                Localized.my_premium_title()
            }
            .bind(to: subscriptionPeriodTypeTitle)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(PremiumService.shared.isAllowTrialPeriod, PremiumService.shared.isUsedTrialPeriod)
            .map { ($0.0 || $0.1) ?
                Localized.premium_three_days_free() :
                Localized.buttonBuy()
            }
            .bind(to: buyButtonTitle)
            .disposed(by: disposeBag)

        fetchSubscriptions()
            .bind(to: activeSubscriptionExpirationDate)
            .disposed(by: disposeBag)
    }
}

extension AboutPremiumInteractor {
    func restorePurchases() -> Observable<Bool> {
        return .create { observer in
            Purchases.shared.restoreTransactions { [weak self] info, _ in
                guard let strongSelf = self, !(info?.activeSubscriptions.isEmpty ?? true), let expirationDate = info?.latestExpirationDate else {
                    observer.onNext(false)
                    observer.onCompleted()
                    return
                }
                
                strongSelf.activeSubscriptionExpirationDate.accept(expirationDate)
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

private extension AboutPremiumInteractor {
    func fetchSubscriptions() -> Observable<Date?> {
        return .create { observer in
            Purchases.shared.purchaserInfo { info, _ in
                guard !(info?.activeSubscriptions.isEmpty ?? true), let expirationDate = info?.latestExpirationDate else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    
                    return
                }
                
                observer.onNext(expirationDate)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    func restore() {
        Purchases.shared.restoreTransactions { [weak self] info, _ in
            guard let strongSelf = self, !(info?.activeSubscriptions.isEmpty ?? true), let expirationDate = info?.latestExpirationDate else {
                self?.activeSubscriptionExpirationDate.accept(nil)
                return
            }
            
            strongSelf.activeSubscriptionExpirationDate.accept(expirationDate)
        }
    }
}
