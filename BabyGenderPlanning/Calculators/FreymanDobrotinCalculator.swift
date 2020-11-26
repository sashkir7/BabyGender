//
//  FreymanDobrotinCalculator.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 21/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

class FreymanDobrotinCalculator: GenderCalculatorType {
    func calculateResultWithBornChild(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date]) -> (gender: Gender, dates: [Date]) {
        var maleDates = [Date]()
        var femaleDates = [Date]()
        
        conceptionDates.forEach { date in
            let gender = calculateResult(father: father, mother: mother, conceptionDate: date)
            gender == .male ? maleDates.append(date) : femaleDates.append(date)
        }
        
        guard !maleDates.isEmpty || !femaleDates.isEmpty else { return (.unknown, []) }
        
        return maleDates.count > femaleDates.count ?
            (.male, maleDates) :
            (.female, femaleDates)
    }
    
    func calculateResultForPlanning(father: ParentInfo, mother: ParentInfo, conceptionDates: [Date], desiredGender: Gender) -> [Date] {
        var maleDates = [Date]()
        var femaleDates = [Date]()
        
        conceptionDates.forEach { date in
            let gender = calculateResult(father: father, mother: mother, conceptionDate: date)
            if gender != .unknown {
                gender == .male ? maleDates.append(date) : femaleDates.append(date)
            }
        }
        
        return desiredGender == .male ?
            maleDates :
            femaleDates
    }
    
    func calculateResult(father: ParentInfo, mother: ParentInfo, conceptionDate: Date) -> Gender {
        let fatherCoefficient = getFatherCoefficient(father, conceptionDate)
        let motherCoefficient = getMotherCoefficient(mother, conceptionDate)
        
        guard fatherCoefficient != motherCoefficient else { return .female }
        
        return fatherCoefficient > motherCoefficient ? .male : .female
    }
    
    func getFatherCoefficient(_ father: ParentInfo, _ conceptionDate: Date) -> Int {
        let first = fatherFirstNumber(birthdayDate: father.birthdayDate, conceptionDate: conceptionDate)
        let second = fatherSecondNumber(birthdayDate: father.birthdayDate)
        let third = fatherThirdNumber(birthdayDate: father.birthdayDate)
        let fourth = fatherFourthNumber(conceptionDate: conceptionDate)
        let fifth = fatherFifthNumber(conceptionDate: conceptionDate)
        
        let fatherSum = [first, second, third, fourth, fifth].reduce(0, +)
        
        let coefficients = [0, 3, 6, 9]
        return getSumCoefficient(sum: fatherSum, coefficients: coefficients)
    }
    
    func getMotherCoefficient(_ mother: ParentInfo, _ conceptionDate: Date) -> Int {
        let first = motherFirstNumber(birthdayDate: mother.birthdayDate, conceptionDate: conceptionDate)
        let second = motherSecondNumber(birthdayDate: mother.birthdayDate)
        let third = motherThirdNumber(birthdayDate: mother.birthdayDate)
        let fourth = motherFourthNumber(conceptionDate: conceptionDate)
        let fifth = motherFifthNumber(conceptionDate: conceptionDate)
        
        let motherSum = [first, second, third, fourth, fifth].reduce(0, +)
        
        let coefficients = [0, 4, 8]
        return getSumCoefficient(sum: motherSum, coefficients: coefficients)
    }
}

// MARK: - Father Numbers

extension FreymanDobrotinCalculator {
    func fatherFirstNumber(birthdayDate: Date, conceptionDate: Date) -> Int {
        let coefficients = [[0, 1, 2],
                            [3, 0, 1],
                            [2, 3, 0],
                            [1, 2, 3],
                            [3, 0, 1],
                            [2, 3, 0],
                            [1, 2, 3],
                            [0, 1, 2],
                            [2, 3, 0],
                            [1, 2, 3],
                            [0, 1, 3],
                            [3, 0, 1],
                            [1, 2, 3],
                            [0, 1, 2],
                            [3, 0, 1],
                            [2, 3, 0]]
        
        return getFirstCoefficient(birthdayDate: birthdayDate,
                                   conceptionDate: conceptionDate,
                                   coefficients: coefficients)
    }
    
    func fatherSecondNumber(birthdayDate: Date) -> Int {
        let nonLeapMonthsCoefficients = [2, 2, 3, 1, 2, 0, 1, 2, 0, 1, 3, 0]
        let leapMonthsCoefficients = [3, 2, 3, 1, 2, 0, 1, 2, 0, 1, 3, 0]
        
        return getCoefficient(at: birthdayDate,
                              nonLeapMonthsCoefficients: nonLeapMonthsCoefficients,
                              leapMonthsCoefficients: leapMonthsCoefficients)
    }
    
    func fatherThirdNumber(birthdayDate: Date) -> Int {
        let thirtyOneDays = [2, 1, 0, 3]
        let thirtyDays = [1, 0, 3, 2]
        let twentyNineDays = [0, 3, 2, 1]
        let twentyEightDays = [3, 2, 1, 0]
        
        return getThirdCoefficient(at: birthdayDate,
                                   thirtyOneDays: thirtyOneDays,
                                   thirtyDays: thirtyDays,
                                   twentyNineDays: twentyNineDays,
                                   twentyEightDays: twentyEightDays)
    }
    
    func fatherFourthNumber(conceptionDate: Date) -> Int {
        let nonLeapMonthsCoefficients = [0, 3, 3, 2, 0, 3, 1, 0, 3, 1, 0, 2]
        let leapMonthsCoefficients = [0, 3, 0, 3, 1, 0, 2, 1, 0, 2, 1, 3]
        
        return getCoefficient(at: conceptionDate,
                              nonLeapMonthsCoefficients: nonLeapMonthsCoefficients,
                              leapMonthsCoefficients: leapMonthsCoefficients)
    }
    
    func fatherFifthNumber(conceptionDate: Date) -> Int {
        let coefficient = conceptionDate.day % kMaleBloodRenewalPeriod
        return coefficient == 0 ? kMaleBloodRenewalPeriod : coefficient
    }
}

// MARK: - Mother Numbers

extension FreymanDobrotinCalculator {
    func motherFirstNumber(birthdayDate: Date, conceptionDate: Date) -> Int {
        let repeatedCoefficients = [[0, 2, 1, 1],
                                    [1, 0, 2, 2],
                                    [2, 1, 0, 0],
                                    [2, 1, 0, 0]]
        
        let coefficients = Array(Array(repeating: repeatedCoefficients, count: 4).joined())
        return getFirstCoefficient(birthdayDate: birthdayDate,
                                   conceptionDate: conceptionDate,
                                   coefficients: coefficients)
    }
    
    func motherSecondNumber(birthdayDate: Date) -> Int {
        let nonLeapMonthsCoefficients = [0, 1, 2, 2, 1, 1, 0, 2, 2, 1, 1, 0]
        let leapMonthsCoefficients = [2, 0, 2, 2, 1, 1, 0, 2, 2, 1, 1, 0]
        
        return getCoefficient(at: birthdayDate,
                              nonLeapMonthsCoefficients: nonLeapMonthsCoefficients,
                              leapMonthsCoefficients: leapMonthsCoefficients)
    }
    
    func motherThirdNumber(birthdayDate: Date) -> Int {
        let thirtyOneDays = [0, 2, 1]
        let thirtyDays = [1, 2, 0]
        let twentyNineDays = [1, 0, 2]
        let twentyEightDays = [0, 2, 1]
        
        return getThirdCoefficient(at: birthdayDate,
                                   thirtyOneDays: thirtyOneDays,
                                   thirtyDays: thirtyDays,
                                   twentyNineDays: twentyNineDays,
                                   twentyEightDays: twentyEightDays)
    }
    
    func motherFourthNumber(conceptionDate: Date) -> Int {
        let nonLeapMonthsCoefficients = [0, 1, 2, 0, 0, 1, 1, 2, 0, 0, 1, 1]
        let leapMonthsCoefficients = [0, 1, 0, 1, 1, 2, 2, 0, 1, 1, 2, 2]
        
        return getCoefficient(at: conceptionDate,
                              nonLeapMonthsCoefficients: nonLeapMonthsCoefficients,
                              leapMonthsCoefficients: leapMonthsCoefficients)
    }
    
    func motherFifthNumber(conceptionDate: Date) -> Int {
        let coefficient = conceptionDate.day % kFemaleBloodRenewalPeriod
        return coefficient
    }
}

// MARK: - Helper methods

extension FreymanDobrotinCalculator {
    func getFirstCoefficient(birthdayDate: Date, conceptionDate: Date, coefficients: [[Int]]) -> Int {
        
        let birthdayYear = birthdayDate.year
        let conceptionYear = conceptionDate.year
        
        let numberOfCoefficients = 16
        let countdownBirthdayYear = 1_912
        let countdownConceptionYear = 1_918

        precondition(coefficients.count == numberOfCoefficients)
        precondition(birthdayYear >= countdownBirthdayYear)
        precondition(conceptionYear >= countdownConceptionYear)

        let separator = coefficients.first?.count ?? 0
        let rowIndex = (birthdayYear - countdownBirthdayYear) % numberOfCoefficients
        let columnIndex = (conceptionYear - countdownConceptionYear) % separator
        
        let row = coefficients[rowIndex, default: []]
        return row[columnIndex, default: 0]
    }
    
    func getCoefficient(at date: Date, nonLeapMonthsCoefficients: [Int], leapMonthsCoefficients: [Int]) -> Int {
        precondition(nonLeapMonthsCoefficients.count == leapMonthsCoefficients.count)
        
        let monthIndex = date.month - 1
        
        return date.isLeapYear ?
            leapMonthsCoefficients[monthIndex, default: 0] :
            nonLeapMonthsCoefficients[monthIndex, default: 0]
    }
    
    func getThirdCoefficient(at date: Date,
                             thirtyOneDays: [Int],
                             thirtyDays: [Int],
                             twentyNineDays: [Int],
                             twentyEightDays: [Int]) -> Int {
        
        precondition(thirtyOneDays.count == thirtyDays.count)
        precondition(thirtyDays.count == twentyNineDays.count)
        precondition(twentyNineDays.count == twentyEightDays.count)
        precondition(twentyEightDays.count == thirtyOneDays.count)
        
        let day = date.day
        let numberOfDaysInMonth = date.numberOfDaysInMonth
        
        let separator = day % thirtyOneDays.count
        let index = (separator == 0 ? thirtyOneDays.count : separator) - 1
        
        switch numberOfDaysInMonth {
            
        case 31:
            return thirtyOneDays[index, default: 0]
            
        case 30:
            return thirtyDays[index, default: 0]
            
        case 29:
            return twentyNineDays[index, default: 0]
            
        case 28:
            return twentyEightDays[index, default: 0]
            
        default:
            return 0
        }
    }
    
    func getSumCoefficient(sum: Int, coefficients: [Int]) -> Int {
        let separator = coefficients.count
        return coefficients[sum % separator]
    }
}
