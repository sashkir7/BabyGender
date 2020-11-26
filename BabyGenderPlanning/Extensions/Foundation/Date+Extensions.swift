//
//  Date+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

private let monday = 2

extension Date {
    var currentAge: Int {
        return yearsTo(secondDate: Date())
    }

    var numberOfDaysInMonth: Int {
        return calendar.range(of: .day, in: .month, for: self)?.count ?? 0
    }

    var day: Int {
        return calendar.component(.day, from: self)
    }

    var month: Int {
        return calendar.component(.month, from: self)
    }

    var year: Int {
        return calendar.component(.year, from: self)
    }

    var isLeapYear: Bool {
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    func yearsTo(secondDate: Date) -> Int {
        return calendar.dateComponents([.year], from: self, to: secondDate).year ?? 0
    }

    func getNextBloodRenewalDate(renewalCycle: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = self.year + renewalCycle
        dateComponents.month = self.month
        dateComponents.day = self.day
        dateComponents.calendar = calendar
        return dateComponents.date ?? self
    }

    private var calendar: Calendar {
        return Calendar.current
    }
    
    static func create(day: Int = Date().day, month: Int = Date().month, year: Int = Date().year) -> Date? {
        let string = String(format: "%02d/%02d/%04d", day, month, year)
        return DateFormatter.formatString(string)
    }
    
    func isEqual(to date: Date) -> Bool {
        return year == date.year && month == date.month && day == date.day
    }
}
