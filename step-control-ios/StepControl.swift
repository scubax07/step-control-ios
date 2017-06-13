//
//  StepControl.swift
//  StepsPager
//
//  Created by Juan Pereira on 6/6/17.
//  Copyright © 2017 Juan Pereira. All rights reserved.
//

import UIKit
import QuartzCore

class Steps: UIControl {

    let minSteps = 2
    let shrinkDotPercentage: CGFloat = 70.0
    let marginBetweenDots: CGFloat = 40.0

    var numberOfSteps = 0 {
        didSet {
            self.createLayers()
        }
    }

    var currentPage = 1 {
        didSet {
            if let sublayers = self.layer.sublayers {
                for index in numberOfSteps-1...sublayers.count-1 {
                    let layer = sublayers[index] as! DotTextLayer
                    layer.isSelected = currentPage == layer.index
                    layer.isCompleted = currentPage > layer.index
                }

                updateLayerFrames()
            }
        }
    }

    var dotsSize: CGFloat {
        return CGFloat(bounds.height)
    }

    var dotsSizeNotSelected: CGFloat {
        return (shrinkDotPercentage * dotsSize) / 100.0
    }

    var connectorLayerYPosition: CGFloat {
        return self.bounds.height / 2.0
    }

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateLayerFrames()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    func updateLayerFrames() {
        //TODO: 
        // - Create class for connectors
        // - General config for steps (colors, transitions)

        setupDotLayers()
        setupConnectLayers()
    }

    func createLayers() {
        var dotLayers = [DotTextLayer]()
        var connectLayers = [CALayer]()

        for index in 1...numberOfSteps {
            let layer = DotTextLayer()
            layer.index = index
            dotLayers.append(layer)
        }

        for _ in 1...numberOfSteps-1 {
            let connectLayer = CALayer()
            connectLayer.backgroundColor = UIColor.gray.cgColor
            connectLayers.append(connectLayer)
        }

        dotLayers.first!.isSelected = true

        connectLayers.forEach { (connectLayer) in
            self.layer.addSublayer(connectLayer)
        }

        dotLayers.forEach { (dotLayer) in
            self.layer.addSublayer(dotLayer)
        }
    }

    fileprivate func xDotPosition(index: Int) -> CGFloat {
        return marginBetweenDots * CGFloat(index)
    }

    fileprivate func yDotPosition(layer: DotTextLayer, size: CGFloat) -> CGFloat {
        if (layer.isSelected) {
            return 0.0
        } else {
            return (self.bounds.height - dotsSizeNotSelected) / 2.0
        }
    }

    fileprivate func setupDotLayers() {
        if let sublayers = self.layer.sublayers {
            var realIndex = 0
            for index in numberOfSteps-1...sublayers.count-1 {
                let layer = sublayers[index] as! DotTextLayer
                let size = layer.isSelected ? dotsSize : dotsSizeNotSelected

                layer.frame = CGRect(x: xDotPosition(index: realIndex), y: yDotPosition(layer: layer, size: dotsSize), width: size, height: size)
                realIndex = realIndex + 1
            }
        }
    }

    fileprivate func setupConnectLayers() {
        if let sublayers = self.layer.sublayers {
            for index in 0...numberOfSteps-2 {
                let connectLayer = sublayers[index]

                if (index + 1 >= currentPage) {
                    connectLayer.backgroundColor = UIColor.gray.cgColor
                } else {
                    connectLayer.backgroundColor = UIColor.orange.cgColor
                }

                connectLayer.frame = CGRect(x: xDotPosition(index: index) + dotsSize / 2.0 , y: connectorLayerYPosition, width: marginBetweenDots, height: 2)
            }
        }
    }
}
