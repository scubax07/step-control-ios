import UIKit
import QuartzCore

class Steps: UIControl {
  
  let minSteps = 2
  let shrinkDotPercentage: CGFloat = 70.0
  let marginBetweenDots: CGFloat = 40.0
  
  var selectedColor = Constants.Colors.selectedColor
  var unselectedColor = Constants.Colors.unselectedColor
  
  var numberOfSteps = 0 {
    didSet {
      createLayers()
    }
  }
  
  var currentPage = 1 {
    didSet {
      if let sublayers = layer.sublayers {
        for index in numberOfSteps - 1...sublayers.count - 1 {
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
    return bounds.height / 2.0
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
    setupDotLayers()
    setupConnectLayers()
  }
  
  func createLayers() {
    layer.sublayers?.removeAll()
    
    let dotLayers = createDotLayers()
    let connectLayers = createConnectLayers()
    
    dotLayers.first!.isSelected = true
    dotLayers.forEach { (dotLayer) in
      layer.addSublayer(dotLayer)
    }
    
    connectLayers.forEach { (connectLayer) in
      layer.addSublayer(connectLayer)
    }
  }
  
  fileprivate func createDotLayers() -> [DotTextLayer] {
    var dotLayers = [DotTextLayer]()
    for index in 1...numberOfSteps {
      let layer = DotTextLayer()
      layer.selectedColor = selectedColor.cgColor
      layer.unselectedColor = unselectedColor.cgColor
      layer.completedColor = selectedColor.cgColor
      layer.index = index
      dotLayers.append(layer)
    }
    return dotLayers
  }
  
  fileprivate func createConnectLayers() -> [CALayer] {
    var connectLayers = [CALayer]()
    for _ in 1...numberOfSteps - 1 {
      let connectLayer = CALayer()
      connectLayer.backgroundColor = unselectedColor.cgColor
      connectLayers.append(connectLayer)
    }
    return connectLayers
  }
  
  fileprivate func xDotPosition(index: Int) -> CGFloat {
    return marginBetweenDots * CGFloat(index)
  }
  
  fileprivate func yDotPosition(layer: DotTextLayer, size: CGFloat) -> CGFloat {
    return layer.isSelected ? 0.0 : (bounds.height - dotsSizeNotSelected) / 2.0
  }
  
  fileprivate func setupDotLayers() {
    if let sublayers = layer.sublayers {
      var realIndex = 0
      for index in numberOfSteps - 1...sublayers.count-1 {
        let layer = sublayers[index] as! DotTextLayer
        let size = layer.isSelected ? dotsSize : dotsSizeNotSelected
        
        layer.frame = CGRect(x: xDotPosition(index: realIndex), y: yDotPosition(layer: layer, size: dotsSize), width: size, height: size)
        realIndex = realIndex + 1
      }
    }
  }
  
  fileprivate func setupConnectLayers() {
    if let sublayers = layer.sublayers {
      for index in 0...numberOfSteps - 2 {
        let connectLayer = sublayers[index]
        
        connectLayer.backgroundColor = index + 1 >= currentPage ? unselectedColor.cgColor : selectedColor.cgColor
        connectLayer.frame = CGRect(x: xDotPosition(index: index) + dotsSize / 2.0 , y: connectorLayerYPosition, width: marginBetweenDots, height: 2)
      }
    }
  }
}
