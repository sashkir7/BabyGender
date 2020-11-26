//
//  Colors.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIColor {

    ///#513434
    static var barossa: UIColor {
        return R.color.barossa().unwrapped
    }

    ///#BA609A
    static var mulberry: UIColor {
        return R.color.mulberry().unwrapped
    }

    ///#F6A8A8
    static var sundown: UIColor {
        return R.color.sundown().unwrapped
    }

    ///#513444
    static var textPrimary: UIColor {
        return R.color.textPrimary().unwrapped
    }

    static var textFieldShadow: UIColor {
        return R.color.textFieldShadow().unwrapped
    }

    static var dropdownShadow: UIColor {
        return R.color.dropdownShadow().unwrapped
    }

    static var viewShadow: UIColor {
        return R.color.viewShadow().unwrapped
    }

    static var selectedSegment: UIColor {
        return R.color.selectedSegment().unwrapped
    }
    
    static var selectedSegmentPink: UIColor {
        return R.color.selectedSegmentPink().unwrapped
    }
    
    static var toastColor: UIColor {
        return R.color.toastColor().unwrapped
    }

    static var appWhite: UIColor {
        return .white
    }

    static var appBlack: UIColor {
        return .black
    }
}

extension Optional where Wrapped: UIColor {
    var unwrapped: UIColor {
        return self ?? UIColor()
    }
}
