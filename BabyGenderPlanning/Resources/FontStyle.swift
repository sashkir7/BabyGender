//
//  FontStyle.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIFont {
    static var generalTextFont: UIFont {
        return .systemFont(ofSize: 15)
    }

    static var titleFont: UIFont {
        return .systemFont(ofSize: 17)
    }

    static var floatTitleFont: UIFont {
        return .systemFont(ofSize: 12)
    }

    var semibold: UIFont {
        return .systemFont(ofSize: pointSize, weight: .semibold)
    }

    var bold: UIFont {
        return .boldSystemFont(ofSize: pointSize)
    }
}
