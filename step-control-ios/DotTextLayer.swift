import Foundation
import UIKit
import QuartzCore

//Help from: https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer
class DotTextLayer: CATextLayer {
  
  let defaultForegroundColor = Constants.Colors.foregroundCGColor
  let defaultFontSize: CGFloat = 14
  let defaultAlignmentMode = "center"
  
  var unselectedColor = Constants.Colors.unselectedCGColor
  var selectedColor = Constants.Colors.selectedCGColor
  var completedColor = Constants.Colors.completedCGColor
  
  var isSelected = false
  var isCompleted = false
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
    let height = bounds.height
    
    if let attributedString = string as? NSAttributedString {
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
    cornerRadius = frame.width / 2.0
  }
}
