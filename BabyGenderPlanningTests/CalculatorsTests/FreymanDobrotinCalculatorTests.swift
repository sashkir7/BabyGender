//
//  FreymanDobrotinCalculatorTests.swift
//  BabyGenderPlanningTests
//
//  Created by Dmitriy Petrov on 19.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

@testable import BabyGenderPlanning
import XCTest

class FreymanDobrotinCalculatorTests: XCTestCase {
    var father: ParentInfo!
    var mother: ParentInfo!
    var dateOfConception: Date!
    var calculator: FreymanDobrotinCalculator!
    
    override func setUp() {
        guard let _ = Date.create(day: 23, month: 7, year: 2010),
            let fatherDateOfBirth = Date.create(day: 20, month: 11, year: 2013),
            let motherDateOfBirth = Date.create(day: 27, month: 2, year: 2009),
            let childConceptionDate = Date.create(day: 29, month: 7, year: 2020) else {
            return
        }
        
        father = ParentInfo(id: "", name: "", gender: .male, birthdayDate: fatherDateOfBirth, bloodGroup: nil)
        
        mother = ParentInfo(id: "", name: "", gender: .female, birthdayDate: motherDateOfBirth, bloodGroup: nil)
        
        dateOfConception = childConceptionDate
        
        calculator = FreymanDobrotinCalculator()
    }
    
    func testCalculateResult() {
        let result = calculator.calculateResult(father: father, mother: mother, conceptionDate: dateOfConception)
        
        XCTAssert(result == .female, "Prediction should return female")
    }
    
    // MARK: - Father coefficent calculation testing
    
    func testGetFatherFirstCoefficent() {
        let result = calculator.fatherFirstNumber(birthdayDate: father.birthdayDate, conceptionDate: dateOfConception)
        
        XCTAssert(result == 2, "Father first number should be 2")
    }
    
    func testGetFatherSecondCoefficent() {
        let result = calculator.fatherSecondNumber(birthdayDate: father.birthdayDate)
        
        XCTAssert(result == 3, "Father second number should be 3")
    }
    
    func testGetFatherThirdCoefficent() {
        let result = calculator.fatherThirdNumber(birthdayDate: father.birthdayDate)
        
        XCTAssert(result == 2, "Father third number should be 2")
    }
    
    func testGetFatherFourthCoefficent() {
        let result = calculator.fatherFourthNumber(conceptionDate: dateOfConception)
        
        XCTAssert(result == 2, "Father fourth number should be 2")
    }
    
    func testGetFatherFifthCoefficent() {
        let result = calculator.fatherFifthNumber(conceptionDate: dateOfConception)
        
        XCTAssert(result == 1, "Father fourth number should be 1")
    }
    
    func testFatherGetSumCoefficient() {
        let sum = 6
        let coefficients = [0, 3, 6, 9]
        
        let result = calculator.getSumCoefficient(sum: sum, coefficients: coefficients)
        
        XCTAssert(result == 6, "Father sum coefficent should be 6")
    }
    
    // MARK: - Mother coefficent calculation testing
    
    func testGetMotherFirstCoefficent() {
        let result = calculator.motherFirstNumber(birthdayDate: mother.birthdayDate, conceptionDate: dateOfConception)
	
        XCTAssert(result == 2, "Mother first number should be 2")

    }
    
    func testGetMotherSecondCoefficent() {
        let result = calculator.motherSecondNumber(birthdayDate: mother.birthdayDate)
        
        XCTAssert(result == 1, "Mother second number should be 1")
    }
    
    func testGetMotherThirdCoefficent() {
        let result = calculator.motherThirdNumber(birthdayDate: mother.birthdayDate)
        
        XCTAssert(result == 1, "Mother third number should be 1")
    }
    
    func testGetMotherFourthCoefficent() {
        let result = calculator.motherFourthNumber(conceptionDate: dateOfConception)
        
        XCTAssert(result == 2, "Mother fourth number should be 2")
    }
    
    func testGetMotherFifthCoefficent() {
        let result = calculator.motherFifthNumber(conceptionDate: dateOfConception)
        
        XCTAssert(result == 2, "Mother fourth number should be 2")
    }
    
    func testMotherGetSumCoefficient() {
        let sum = 8
        let coefficients = [0, 4, 8]
        
        let result = calculator.getSumCoefficient(sum: sum, coefficients: coefficients)
        
        XCTAssert(result == 8, "Mother sum coefficent should be 4")
    }
}
