//
//  DateFormat.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 16/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

enum DateFormat: String {
    case ddMMYYYY = "dd/MM/yyyy"
}

extension DateFormatter {
    private static let formatter = DateFormatter()

    static func formatDate(_ date: Date, dateFormat: DateFormat) -> String {
        formatter.dateFormat = dateFormat.rawValue
        return formatter.string(from: date)
    }
    
    static func formatString(_ string: String, dateFormat: DateFormat = .ddMMYYYY) -> Date? {
        formatter.dateFormat = dateFormat.rawValue
        return formatter.date(from: string)
    }
}

extension Date {
    func format(dateFormat: DateFormat) -> String {
        return DateFormatter.formatDate(self, dateFormat: dateFormat)
    }
}
