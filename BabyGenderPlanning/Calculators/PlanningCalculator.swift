//
//  PlanningCalculator.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 01.07.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

class PlanningCalculator {
    let bloodCalculator: BloodCalculator
    let freymanDobrotinCalculator: FreymanDobrotinCalculator
    let conceptionDateCalculator: ConceptionDateCalculator
    
    init(bloodCalculator: BloodCalculator = .init(),
         freymanDobrotinCalculator: FreymanDobrotinCalculator = .init(),
         conceptionDateCalculator: ConceptionDateCalculator = .init()) {
        self.bloodCalculator = bloodCalculator
        self.freymanDobrotinCalculator = freymanDobrotinCalculator
        self.conceptionDateCalculator = conceptionDateCalculator
    }
    
    func calculateByBlood(father: ParentInfo, mother: ParentInfo, periodInMonth: Int, desiredGender: Gender) -> CalculationInfo? {
        let conceptionDates = conceptionDateCalculator.getDatesOfConception(from: periodInMonth)
        
        let dates = bloodCalculator.calculateResultForPlanning(father: father, mother: mother, conceptionDates: conceptionDates, desiredGender: desiredGender)
        
        guard let planningResults = parseDates(dates) else { return nil }
        
        return CalculationInfo(id: randomUUID,
                               method: .bloodRenewal,
                               gender: desiredGender,
                               calculationDate: Date(),
                               father: father,
                               mother: mother,
                               planningResults: planningResults)
    }
    
    func calculateByFreymanDobrotin(father: ParentInfo, mother: ParentInfo, periodInMonth: Int, desiredGender: Gender) -> CalculationInfo? {
        let conceptionDates = conceptionDateCalculator.getDatesOfConception(from: periodInMonth)
        
        let dates = freymanDobrotinCalculator
            .calculateResultForPlanning(father: father, mother: mother, conceptionDates: conceptionDates, desiredGender: desiredGender)
        
        guard let planningResults = parseDates(dates) else { return nil }
        
        return CalculationInfo(id: randomUUID,
                               method: .freymanDobroting,
                               gender: desiredGender,
                               calculationDate: Date(),
                               father: father,
                               mother: mother,
                               planningResults: planningResults)
    }
}

// MARK: - Helper methods

extension PlanningCalculator {
    func parseDates(_ dates: [Date]) -> [PlanningResultInfo]? {
        guard !dates.isEmpty else { return nil }
        
        let datesDictionary = Dictionary(grouping: dates, by: { $0.month })
        
        let planningResults = datesDictionary
            .compactMap { dict -> PlanningResultInfo? in
                guard let month = Month(rawValue: dict.key - 1),
                    let year = dict.value.first?.year else { return nil }
                
                let days = dict.value.map { $0.day }
                
                return PlanningResultInfo(id: randomUUID, month: month, year: year, days: days)
            }
            .sorted(by: { lhs, rhs in
                guard lhs.year == rhs.year else {
                    return lhs.year < rhs.year
                }
                return lhs.month.rawValue < rhs.month.rawValue
            })
        
        return planningResults
    }
}
