//
//  BloodCalculatorTests.swift
//  BabyGenderPlanningTests
//
//  Created by Dmitriy Petrov on 19.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

@testable import BabyGenderPlanning
import XCTest

class BloodCalculatorTests: XCTestCase {
    var mother: ParentInfo!
    var father: ParentInfo!
    var conceptionDate: Date!
    var calculator: BloodCalculator!
    
    override func setUp() {
        mother = ParentInfo(id: "", name: "", gender: .female, birthdayDate: Date(), bloodGroup: BloodGroupInfo(id: "", level: 1, rhesusFactor: .positive))
        father = ParentInfo(id: "", name: "", gender: .male, birthdayDate: Date(), bloodGroup: BloodGroupInfo(id: "", level: 1, rhesusFactor: .positive))
        conceptionDate = Date.create(day: 29, month: 08, year: 2020)
        calculator = BloodCalculator()
    }

    func testCheckResultWithoutBloodLoss_motherBloodUpdatedLater() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest firstMother blood updated -> 02.09.2019
        mother.birthdayDate = Date.create(day: 02, month: 09, year: 1995)!
        // Latest firstFather blood updated -> 24.02.2017
        father.birthdayDate = Date.create(day: 24, month: 02, year: 1993)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .female, "Prediction should return .female")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .male, "Prediction should return .male")
    }

    func testCheckResultWithoutBloodLoss_fatherBloodUpdatedLater() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest secondMother blood updated -> 01.07.2018
        mother.birthdayDate = Date.create(day: 01, month: 07, year: 2000)!
        // Latest secondFather blood updated -> 23.09.2019
        father.birthdayDate = Date.create(day: 23, month: 09, year: 1999)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .male, "Prediction should return .male")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .female, "Prediction should return .female")
    }

    func testCheckResultWithoutBloodLoss_bloodUpdatedIsEqual() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest thirdMother blood updated -> 02.03.2019
        mother.birthdayDate = Date.create(day: 02, month: 03, year: 2001)!
        // Latest thirdFather blood updated -> 02.03.2019
        father.birthdayDate = Date.create(day: 02, month: 03, year: 1999)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .female, "Prediction should return .female")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .female, "Prediction should return .female")
    }

    func testCheckResultWithLossBlood_fatherHadBloodLoss() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest firstMother blood updated -> 22.01.2020
        mother.birthdayDate = Date.create(day: 22, month: 01, year: 2020)!
        // Latest firstFather blood updated -> 08.12.2018
        father.birthdayDate = Date.create(day: 31, month: 08, year: 2001)!
        father.bloodLossDate = Date.create(day: 08, month: 12, year: 2018)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .female, "Prediction should return .female")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .male, "Prediction should return .male")
    }

    func testCheckResultWithLossBlood_motherHadBloodLoss() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest secondMother blood updated -> 01.03.2019
        mother.birthdayDate = Date.create(day: 17, month: 01, year: 2001)!
        mother.bloodLossDate = Date.create(day: 01, month: 03, year: 2019)!
        // Latest secondFather blood updated -> 18.03.2018
        father.birthdayDate = Date.create(day: 18, month: 03, year: 1990)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .female, "Prediction should return .female")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .male, "Prediction should return .male")
    }

    func testCheckResultWithLossBlood_parentsTogetherHadBloodLoss() {
        guard let conceptionDate = conceptionDate, var mother = mother, var father = father else { return }

        // Latest thirdMother blood updated -> 03.05.2019
        mother.birthdayDate = Date.create(day: 30, month: 07, year: 1960)!
        mother.bloodLossDate = Date.create(day: 03, month: 05, year: 2007)!
        // Latest thirdFather blood updated -> 03.05.2019
        father.birthdayDate = Date.create(day: 07, month: 05, year: 1945)!
        father.bloodLossDate = Date.create(day: 03, month: 05, year: 2007)!

        let resultPositiveRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultPositiveRhesus == .female, "Prediction should return .female")

        mother.bloodGroup?.rhesusFactor = .negative
        let resultNegativeRhesus = calculator.calculateResult(father: father, mother: mother, conceptionDate: conceptionDate)
        XCTAssert(resultNegativeRhesus == .female, "Prediction should return .female")
    }
}
