//
//  ToastMessage.swift
//  BabyGenderPlanning
//
//  Created by Dmitriy Petrov on 26.06.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

enum ToastMessage {
    case missingInput
    case unknownGender
    case noFavorableDates
    case conceptionDateInvalid
    case bloodLossDateInvalid
    case acceptPolicy
    
    var message: String {
        switch self {
        case .missingInput:
            return Localized.toast_missingInput()
        case .unknownGender:
            return Localized.toast_unknownGender()
        case .noFavorableDates:
            return Localized.toast_noFavorableDates()
        case .conceptionDateInvalid:
            return Localized.toast_conceptionDateInvalid()
        case .bloodLossDateInvalid:
            return Localized.toast_bloodLossDateInvalid()
        case .acceptPolicy:
            return Localized.toast_acceptPolicy()
        }
    }
}
