//
//  ImageButton.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 14/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

class ImageButton: IndentButton {

    init(image: UIImage?) {
        super.init(frame: .zero)
        self.setImage(image, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
