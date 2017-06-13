//
//  DotTextLayer.swift
//  StepsPager
//
//  Created by Juan Pereira on 6/7/17.
//  Copyright © 2017 Juan Pereira. All rights reserved.
//
// with help of https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer

import Foundation
import UIKit
import QuartzCore

class DotTextLayer: CATextLayer {

    let defaultFontSize: CGFloat = 14
    let defaultForegroundColor = UIColor.white.cgColor
    let defaultAlignmentMode = "center"

    var isSelected = false
    var isCompleted = false
    var unselectedColor = UIColor.gray.cgColor
    var selectedColor = UIColor.orange.cgColor
    var completedColor = UIColor.orange.cgColor
    var index = 0

    override var frame: CGRect {
        didSet {
            setDefaultValues()
            setNeedsDisplay()
        }
    }

    override open func draw(in ctx: CGContext) {
        let yDiff: CGFloat
        let fontSize: CGFloat
        let height = self.bounds.height

        if let attributedString = self.string as? NSAttributedString {
            fontSize = attributedString.size().height
            yDiff = (height-fontSize)/2
        } else {
            fontSize = self.fontSize
            yDiff = (height-fontSize)/2 - fontSize/10
        }

        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }

    fileprivate func setDefaultValues() {
        if (isCompleted) {
            string = "✓"
            backgroundColor = completedColor
        } else if (isSelected) {
            string = String(index)
            backgroundColor = selectedColor
        } else {
            string = nil
            backgroundColor = unselectedColor
        }

        foregroundColor = defaultForegroundColor
        fontSize = defaultFontSize
        alignmentMode = defaultAlignmentMode
        cornerRadius = self.frame.width / 2.0
    }
}
