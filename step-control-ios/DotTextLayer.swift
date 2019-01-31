import Foundation
import UIKit
import QuartzCore

//Help from https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer
class DotTextLayer: CATextLayer {

  let defaultFontSize      = CGFloat(14)
  let defaultAlignmentMode = "center"
  var completedString      = "✓"
  var pendingString        = "·"
  
  var isSelected  = false
  var isCompleted = false
  var index       = 0
  var unselectedColor = Constants.Colors.unselectedCGColor
  var selectedColor   = Constants.Colors.selectedCGColor
  var completedColor  = Constants.Colors.completedCGColor

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
      yDiff = (height-fontSize) / 2
    } else {
      fontSize = self.fontSize
      yDiff = (height-fontSize) / 2 - fontSize / 10
    }

    ctx.saveGState()
    ctx.translateBy(x: 0.0, y: yDiff)
    super.draw(in: ctx)
    ctx.restoreGState()
  }

  fileprivate func setDefaultValues() {
    let stringAndBkgColor = getStringAndBackgroundColor()

    string          = stringAndBkgColor.string
    backgroundColor = stringAndBkgColor.backgroundColor
    foregroundColor = Constants.Colors.foregroundCGColor
    fontSize        = defaultFontSize
    alignmentMode   = convertToCATextLayerAlignmentMode(defaultAlignmentMode)
    cornerRadius    = frame.width / 2.0
  }

  fileprivate func getStringAndBackgroundColor() -> (string: String, backgroundColor: CGColor) {
    if (isCompleted) {
      return (completedString, completedColor)
    } else if (isSelected) {
      return (String(index), selectedColor)
    } else {
      return (pendingString, unselectedColor)
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATextLayerAlignmentMode(_ input: String) -> CATextLayerAlignmentMode {
  return CATextLayerAlignmentMode(rawValue: input)
}
