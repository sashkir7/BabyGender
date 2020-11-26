//
//  SubscriptionsInteractor.swift
//  BabyGenderPlanning
//
//  Created by Albert Musagitov on 30.04.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Purchases

final class SubscriptionsInteractor {
    var purchaseOptions = BehaviorRelay<[Purchases.Package]>(value: [])

    var oneMonthButtonTitle = BehaviorRelay<String?>(value: nil)
    var threeMonthButtonTitle = BehaviorRelay<String?>(value: nil)
    var sixMonthButtonTitle = BehaviorRelay<String?>(value: nil)
    var oneYearButtonTitle = BehaviorRelay<String?>(value: nil)

    var threeMonthSaleTitle = BehaviorRelay<String?>(value: nil)
    var sixMonthSaleTitle = BehaviorRelay<String?>(value: nil)
    var oneYearSaleTitle = BehaviorRelay<String?>(value: nil)

    private let disposeBag = DisposeBag()

    private var oneMonthPrice = 0.0
    
    init() {
        fetchOptions()
            .bind(to: purchaseOptions)
            .disposed(by: disposeBag)
    }
}

extension SubscriptionsInteractor {
    func purchaseOption(atIndex index: Int) -> Observable<Bool> {
        guard purchaseOptions.value.count >= index + 1 else {
            return .just(false)
        }
        
        let option = purchaseOptions.value[index]
        return purchaseOption(option)
    }
}

private extension SubscriptionsInteractor {
    func fetchOptions() -> Observable<[Purchases.Package]> {
        return .create { observer in
            Purchases.shared.offerings { offerings, error in
                guard error != nil else {
                    if let options = offerings?.offering(identifier: "premium")?.availablePackages {
                        observer.onNext(options)
                        observer.onCompleted()

                        guard let oneMonthPrice = self.getOneMonthSubscriptionPrice(from: options) else {
                            return
                        }
                        
                        self.oneMonthPrice = oneMonthPrice

                        for package in options {
                            let price = Double(truncating: package.product.price)
                            let priceString = package.localizedPriceString

                            switch package.packageType {
                            case .monthly:
                                let buttonTitle = "\(priceString) \(Localized.subscription_oneMonth())"
                                self.oneMonthButtonTitle.accept(buttonTitle)
                            case .threeMonth:
                                let sale = self.calculateSaleSize(price: price, monthCount: 3)
                                let buttonTitle = "\(priceString) \(Localized.subscription_threeMonths())"
                                let saleTitle = "\(Localized.subscription_threeMonths_saving()) \(sale)%"
                                self.threeMonthButtonTitle.accept(buttonTitle)
                                self.threeMonthSaleTitle.accept(saleTitle)
                            case .sixMonth:
                                let sale = self.calculateSaleSize(price: price, monthCount: 6)
                                let buttonTitle = "\(priceString) \(Localized.subscription_sixMonths())"
                                let saleTitle = "\(Localized.subscription_sixMonths_saving()) \(sale)%"
                                self.sixMonthButtonTitle.accept(buttonTitle)
                                self.sixMonthSaleTitle.accept(saleTitle)
                            case .annual:
                                let sale = self.calculateSaleSize(price: price, monthCount: 12)
                                let buttonTitle = "\(priceString) \(Localized.subscription_oneYear())"
                                let saleTitle = "\(Localized.subscription_oneYear_saving()) \(sale)%"
                                self.oneYearButtonTitle.accept(buttonTitle)
                                self.oneYearSaleTitle.accept(saleTitle)
                            default:
                                continue
                            }
                        }
                    }

                    Purchases.shared.purchaserInfo { purchasesInfo, _ in
                        guard let purchasesInfo = purchasesInfo,
                            let activeSubscription = Array(purchasesInfo.activeSubscriptions).first,
                            let latestExpirationDate = purchasesInfo.latestExpirationDate else {
                                return
                        }

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        let stringLatestExpirationDate = "\(Localized.subscription_valid_until()) \(dateFormatter.string(from: latestExpirationDate))"

                        if activeSubscription == "com.bytepace.bgp.one_month_subscription" {
                            if let oldText = self.oneMonthButtonTitle.value {
                                self.oneMonthButtonTitle.accept("\(oldText)\n\(stringLatestExpirationDate)")
                            }

                        } else if activeSubscription == "com.bytepace.bgp.three_months_subscription" {
                            if let oldText = self.threeMonthButtonTitle.value {
                                self.threeMonthButtonTitle.accept("\(oldText)\n\(stringLatestExpirationDate)")
                            }

                        } else if activeSubscription == "com.bytepace.bgp.six_months_subscription" {
                            if let oldText = self.sixMonthButtonTitle.value {
                                self.sixMonthButtonTitle.accept("\(oldText)\n\(stringLatestExpirationDate)")
                            }

                        } else if activeSubscription == "com.bytepace.bgp.one_year_subscription" {
                            if let oldText = self.oneYearButtonTitle.value {
                                self.oneYearButtonTitle.accept("\(oldText)\n\(stringLatestExpirationDate)")
                            }
                        }
                    }
                    
                    return
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func purchaseOption(_ option: Purchases.Package) -> Observable<Bool> {
        return .create { observer in
            Purchases.shared.purchasePackage(option) { _, info, _, _ in
                guard info?.entitlements.active.first?.value.isActive != nil else {
                    observer.onNext(false)
                    observer.onCompleted()
                    return
                }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    private func getOneMonthSubscriptionPrice(from packages: [Purchases.Package]) -> Double? {
        let package = packages.first(where: {
            $0.packageType == .monthly
        })

        return package?.product.price.doubleValue
    }

    private func calculateSaleSize(price: Double, monthCount: Int) -> Int {
        let result = (price / Double(monthCount) * 100) / oneMonthPrice
        return 100 - Int(result)
    }
}
