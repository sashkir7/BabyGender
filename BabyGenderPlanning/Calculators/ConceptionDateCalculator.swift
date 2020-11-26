//
//  ConceptionDateCalculator.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 21.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

class ConceptionDateCalculator {
    func getDatesOfConceptionText(with data: BornChildData) -> String? {
        let leftRangeOfConceptionDate = getDateFrom(with: data)
        let rightRangeOfConceptionDate = getDateTo(with: data)
        
        guard let leftRangeDate = leftRangeOfConceptionDate,
            let rightRangeDate = rightRangeOfConceptionDate else { return nil }
        
        let leftRangeString = DateFormatter.formatDate(leftRangeDate, dateFormat: .ddMMYYYY)
        let rightRangeString = DateFormatter.formatDate(rightRangeDate, dateFormat: .ddMMYYYY)
        
        return Localized.conceptionDate() + "\n" + leftRangeString + " - " + rightRangeString
    }
    
    func getDatesOfConception(with data: BornChildData) -> [Date] {
        let leftRangeOfConceptionDate = getDateFrom(with: data)
        let rightRangeOfConceptionDate = getDateTo(with: data)
        
        guard var dateFrom = leftRangeOfConceptionDate,
            let dateTo = rightRangeOfConceptionDate,
            dateFrom < dateTo else { return [] }
        
        var dates = [Date]()
        
        while dateFrom <= dateTo {
            dates.append(dateFrom)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom) else {
                break
            }
            dateFrom = newDate
        }
        
        return dates
    }
    
    func getDatesOfConception(from periodInMonth: Int) -> [Date] {
        guard periodInMonth > 0 else { return [] }
        
        var dateFrom = Date()
        let rightRangeDate = Calendar.current.date(byAdding: .month, value: periodInMonth, to: dateFrom)
        
        guard let lastDate = rightRangeDate,
            dateFrom < lastDate else { return [] }
        
        var dates = [Date]()
        
        while dateFrom <= lastDate {
            dates.append(dateFrom)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom) else {
                break
            }
            dateFrom = newDate
        }
        
        return dates
    }
}

// MARK: - Helper methods

private extension ConceptionDateCalculator {
    func getDateFrom(with data: BornChildData) -> Date? {
        let leftRangeNumberOfWeeks = -(data.numberOfWeeks + 1)
        return Calendar.current.date(byAdding: .weekOfYear,
                                     value: leftRangeNumberOfWeeks,
                                     to: data.dateOfBirth)
    }
    
    func getDateTo(with data: BornChildData) -> Date? {
        let rightRangeNumberOfWeeks = -data.numberOfWeeks
        return Calendar.current.date(byAdding: .weekOfYear,
                                     value: rightRangeNumberOfWeeks,
                                     to: data.dateOfBirth)
    }
}
