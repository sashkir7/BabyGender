//
//  AcceptPolicy.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 01.09.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

class AcceptPolicyService {

    private enum SettingPolicyKeys: String {
        case isAcceptPolicy = "AcceptPolicyService.isAcceptPolicy"
    }

    static var isAcceptPolicy: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingPolicyKeys.isAcceptPolicy.rawValue)
        } set {
            UserDefaults.standard.set(newValue, forKey: SettingPolicyKeys.isAcceptPolicy.rawValue)
        }

    }
}
