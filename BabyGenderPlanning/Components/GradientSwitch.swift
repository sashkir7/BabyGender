//
//  GradientSwitch.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 24/02/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GradientSwitch: UISwitch {
        
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.styledViewCornerRadius
        
        applyGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GradientSwitch {
    private func applyGradient() {
        if #available(iOS 13, *) {
            onTintColor = UIColor(170, 75, 151)
            return
        }
        
        tintColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 0.16)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = GradientColors.purple.value
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.frame = bounds
        gradientLayer.opacity = 1
        gradientLayer.isOpaque = true
        gradientLayer.drawsAsynchronously = true
        
        onTintColor = createGradientColor(gradientLayer)
    }
    
    private func createGradientColor(_ layer: CALayer) -> UIColor? {
        let width = Int(layer.frame.size.width)
        let height = Int(layer.frame.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let rawData = malloc(height * bytesPerRow)
        let bitsPerComponent = 8
        guard let context = CGContext(data: rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Big.rawValue)
        else { return nil }
        
        context.clear(layer.bounds)
        
        if layer.contentsAreFlipped() {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: layer.frame.size.height)
            context.concatenate(flipVertical)
        }

        layer.render(in: context)
        
        guard let cgImage = context.makeImage() else {
            free(rawData)
            return nil
        }
        free(rawData)

        return UIColor(patternImage: UIImage(cgImage: cgImage))
    }
}
