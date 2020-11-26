//
//  UIView+Gradient.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 08/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import UIKit

extension UIView {
    func applyGradient(colors: GradientColors, locations: [NSNumber]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
        let gradientLayer = getGradientLayer()
        updateGradientLayer(gradientLayer, colors.value, startPoint, endPoint, locations)
    }

    func applyGradient(cgColors: [CGColor], locations: [NSNumber]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
        let gradientLayer = getGradientLayer()
        updateGradientLayer(gradientLayer, cgColors, startPoint, endPoint, locations)
    }

    func removeGradientIfExists() {
        guard let gradientLayer = layer.sublayers?.first(where: { return $0 is CAGradientLayer }) as? CAGradientLayer else { return }
        gradientLayer.removeFromSuperlayer()
    }

    private func getGradientLayer() -> CAGradientLayer {
        let gradientLayers = layer.sublayers?.compactMap { $0 as? CAGradientLayer }

        guard let gradientLayer = gradientLayers?.first else {
            addGradientLayer()
            return getGradientLayer()
        }

        return gradientLayer
    }

    private func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func updateGradientLayer(_ gradientLayer: CAGradientLayer, _ cgColors: [CGColor], _ startPoint: CGPoint?, _ endPoint: CGPoint?, _ locations: [NSNumber]?) {
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.colors = cgColors

        if let startPoint = startPoint, let endPoint = endPoint {
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
        } else {
            gradientLayer.locations = locations
        }
    }
}
