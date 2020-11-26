//
//  IndentButton.swift
//  BabyGenderPlanning
//
//  Created by KIREEV ALEXANDER on 07.08.2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class IndentButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -10, dy: -10).contains(point)
    }
}
