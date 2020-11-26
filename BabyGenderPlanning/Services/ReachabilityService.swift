//
//  ReachabilityService.swift
//  BabyGenderPlanning
//
//  Created by Alexander Kireev on 17.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityService {
    static let shared = ReachabilityService()
    var reachibility = try? Reachability()
    var isInternetActive: Bool = false
    
    func setupReachibility() {
        reachibility?.whenReachable = { _ in
            self.isInternetActive = true
        }
        reachibility?.whenUnreachable = { _ in
            self.isInternetActive = false
        }
        
        try? reachibility?.startNotifier()
    }
}
