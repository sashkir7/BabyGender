//
//  BabyGenderPlanningTests.swift
//  BabyGenderPlanningTests
//
//  Created by Nikita Velichkin on 20/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import XCTest
@testable import BabyGenderPlanning

class BabyGenderPlanningTests: XCTestCase {
    var father: ParentInfo!
    var mother: ParentInfo!
    var calculator: PlanningCalculator!
    var conceptionDates: Date!
    
    override func setUp() {
        guard let motherDateOfBirth = Date.create(day: 28, month: 07, year: 2002),
        let fatherDateOfBirth = Date.create(day: 28, month: 07, year: 2018) else { return }
        father = ParentInfo(id: "", name: "", gender: .male, birthdayDate: fatherDateOfBirth, bloodGroup: nil)
        mother = ParentInfo(id: "", name: "", gender: .female, birthdayDate: motherDateOfBirth, bloodGroup: nil)
        calculator = PlanningCalculator ()
    }
    func testGetResultPlanningDobrotin() {
        guard let result = calculator.calculateByFreymanDobrotin(father: father, mother: mother, periodInMonth: 1, desiredGender: .female) else { return }
        let planningResults = result.planningResults
        
        XCTAssert(planningResults.contains(where: { val in
            if val.month == .august {
                let days = val.days
                let value = days == [19, 20, 23, 27, 28, 29, 31]
                return value
            }
            return false
        }), "Planning days do not match")
    }
    func testGetResultPlanningBlood() {
        guard let result = calculator.calculateByBlood(father: father, mother: mother, periodInMonth: 1, desiredGender: .female) else { XCTAssert(false); return }
        let planningResults = result.planningResults
        
       XCTAssert(planningResults.contains(where: { val in
            if val.month == .august {
                let days = val.days
                let value = days == [Int](18...31)
                return value
            }
            return false
        }), "Planning days do not match")
    }
}
