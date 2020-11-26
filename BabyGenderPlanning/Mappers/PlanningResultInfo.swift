//
//  PlanningResultInfo.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 30.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation
import UIKit

struct PlanningResultInfo {
    var id: String
    var month: Month
    var year: Int
    var days: [Int]

    var realmObject: PlanningResult {
        return PlanningResult(id: id, month: month, year: year, days: days)
    }

    init(realmObject: PlanningResult) {
        self.id = realmObject.id
        self.month = realmObject.month
        self.year = realmObject.year
        self.days = Array(realmObject.days)
    }

    init(id: String, month: Month, year: Int, days: [Int]) {
        self.id = id
        self.month = month
        self.year = year
        self.days = days
    }
    
    var monthLocalized: String {
        switch month {
        case .january:
            return Localized.january()
        case .february:
            return Localized.february()
        case .march:
            return Localized.march()
        case .april:
            return Localized.april()
        case .may:
            return Localized.may()
        case .june:
            return Localized.june()
        case .july:
            return Localized.july()
        case .august:
            return Localized.august()
        case .september:
            return Localized.september()
        case .october:
            return Localized.october()
        case .november:
            return Localized.november()
        case .december:
            return Localized.december()
        case .unknown:
            return ""
        }
    }
    
    var conceptionDatesString: NSAttributedString? {
        guard !days.isEmpty else { return nil }
        
        let fullAttrString = NSMutableAttributedString()
        
        let monthAttrString = NSAttributedString(monthLocalized, font: UIFont.floatTitleFont.bold, textColor: .mulberry)
        
        let daysString = ": " + days.map(String.init).joined(separator: ", ")
        let daysAttrString = NSAttributedString(daysString, font: .floatTitleFont, textColor: .barossa)
        
        fullAttrString.append(monthAttrString)
        fullAttrString.append(daysAttrString)
        
        return fullAttrString
    }
}
