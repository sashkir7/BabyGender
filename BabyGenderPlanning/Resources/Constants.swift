//
//  Constants.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 25/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

struct Constants {
    static let styledViewCornerRadius: CGFloat = 16

    static let supportEmail = "bytepace.bgp@gmail.com"
    
    // MARK: - Revenue Cat
    
    static let apiKey = "aJmhhPzubdiuXIxEARyQHQQywRFhriex"
    
    static let oneMonthID = "com.bytepace.bgp.one_month_subscription"
    static let threeMonthsID = "com.bytepace.bgp.three_months_subscription"
    static let sixMonthsID = "com.bytepace.bgp.six_months_subscription"
    static let oneYearID = "com.bytepace.bgp.one_year_subscription"
}

var randomUUID: String {
    return UUID().uuidString
}
