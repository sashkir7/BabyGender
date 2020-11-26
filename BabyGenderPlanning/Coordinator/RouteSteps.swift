//
//  RouteSteps.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RxFlow

enum RouteStep: Step {
    case dismiss
    case dismissAndPass(data: ReceivableType)
    case pop
    case popTo(vc: UIViewController.Type)
    case okAlert(title: String? = nil, message: String? = nil)

    case start
    case genderPrediction
    case showContainer(for: ReusableView)
    case planning(father: ParentInfo? = nil, mother: ParentInfo? = nil)
    case parents
    case savedResults
    case support
    case aboutApp
    
    case newPlanning

    // MARK: - Parent Flow

    case deleteParent(onDelete: ((UIAlertAction) -> Void))
    case updateParent(parent: ParentInfo?)
    case saveParent
    case backParent(onBack: ((UIAlertAction) -> Void))
    
    // MARK: - Calculations flow
    
    case deleteCalculation(onDelete: ((UIAlertAction) -> Void))
    case showAllDates(calculationInfo: CalculationInfo)
    case recommendations(gender: Gender)
    
    // MARK: - Premium Flow
    
    case premium(fromMenu: Bool)
    case subscriptions
    case showWarningAlert(title: String? = nil, message: String? = nil)
    case trial
}
