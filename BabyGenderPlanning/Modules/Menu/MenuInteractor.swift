//
//  MenuInteractor.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxSwift
import RxCocoa
import Purchases

final class MenuInteractor {

    var isSubscriptionActive = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()

    var rows: [MenuRow] = {
        return [
            .init(icon: Image.menuBabyQuestion(), title: Localized.sideMenu_genderPrediction(), step: .genderPrediction, isPremiumFeature: false),
            .init(icon: Image.menuPremium(), title: Localized.sideMenu_premium(), step: .premium(fromMenu: true)),
            .init(icon: Image.menuBaby(), title: Localized.sideMenu_planning(), step: .planning()),
            .init(icon: Image.menuParents(), title: Localized.sideMenu_parents(), step: .parents),
            .init(icon: Image.menuCheckmark(), title: Localized.sideMenu_savedResults(), step: .savedResults),
            .init(icon: Image.menuWrite(), title: Localized.sideMenu_write(), step: .support, isPremiumFeature: false),
            .init(icon: Image.menuInfo(), title: Localized.sideMenu_about(), step: .aboutApp, isPremiumFeature: false)]
    }()

    init() {
        PremiumService.shared.purchaserInfo.map { !($0?.entitlements.active.isEmpty ?? false) }.bind(to: isSubscriptionActive).disposed(by: disposeBag)
    }
}
