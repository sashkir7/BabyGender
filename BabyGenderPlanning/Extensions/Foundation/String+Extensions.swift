//
//  String+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 26.05.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

extension String {
    func trim(to count: Int) -> String {
        return String(self.prefix(count))
    }
}

// MARK: - TextField Validation

extension String {
    var isValidNumberOfWeeks: Bool {
        let regex = "[0-9]{2}"
        return evaluate(regex: regex)
    }
    
    func evaluate(regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
