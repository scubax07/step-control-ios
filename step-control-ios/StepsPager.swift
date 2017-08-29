import UIKit

public protocol  StepControlDataSource {
  func numberOfItems(viewPager: StepControl) -> Int
  func viewAtIndex(viewPager: StepControl, index:Int, view:UIView?) -> UIView
}

public enum Position {
  case top, bottom
}

open class StepControl: UIView {
  
  public var dataSource: StepControlDataSource? = nil {
    didSet {
      reloadData()
    }
  }
  
  public var controlBackgroundColor = UIColor.orange {
    didSet {
      pageControl.selectedColor = controlBackgroundColor
      reloadData()
    }
  }
  
  public var controlNotSelectedColor = UIColor.gray {
    didSet {
      pageControl.unselectedColor = controlNotSelectedColor
      reloadData()
    }
  }
  
  public var position: Position = .top {
    didSet {
      reloadData()
    }
  }
  
  fileprivate var pageControl = Steps()
  fileprivate var scrollView = UIScrollView()
  fileprivate var currentPosition = 0
  fileprivate var numberOfItems = 0
  fileprivate var itemViews: Dictionary<Int, UIView> = [:]
  
  private var pageControlWidth: CGFloat {
    return ((pageControl.shrinkDotPercentage * 30.0) / 100.0) + (pageControl.marginBetweenDots * CGFloat(numberOfItems - 1))
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  fileprivate func setupView() {
    addSubview(scrollView)
    addSubview(pageControl)
    
    setupScrollView()
    setupPageControl()
  }
  
  fileprivate func setupScrollView() {
    scrollView.isPagingEnabled = true
    scrollView.alwaysBounceHorizontal = false
    scrollView.bounces = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.delegate = self
    
    let topConstraint = NSLayoutConstraint(item: scrollView, attribute:
      .top, relatedBy: .equal, toItem: self,
            attribute: NSLayoutAttribute.top, multiplier: 1.0,
            constant: 0)
    
    let bottomContraints = NSLayoutConstraint(item: scrollView, attribute:
      .bottom, relatedBy: .equal, toItem: self,
               attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
               constant: 0)
    
    let leftContraints = NSLayoutConstraint(item: scrollView, attribute:
      .leadingMargin, relatedBy: .equal, toItem: self,
                      attribute: .leadingMargin, multiplier: 1.0,
                      constant: 0)
    
    let rightContraints = NSLayoutConstraint(item: scrollView, attribute:
      .trailingMargin, relatedBy: .equal, toItem: self,
                       attribute: .trailingMargin, multiplier: 1.0,
                       constant: 0)
    
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([topConstraint, rightContraints, leftContraints, bottomContraints])
  }
  
  fileprivate func setupPageControl() {
    pageControl.selectedColor =  controlBackgroundColor
    pageControl.unselectedColor =  controlNotSelectedColor
    pageControl.backgroundColor = UIColor.clear
    
    setPageControlPosition()
  }
  
  fileprivate func setPageControlPosition() {
    let heightConstraint = NSLayoutConstraint(item: pageControl, attribute:
      .height, relatedBy: .equal, toItem: nil,
               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0,
               constant: 30)
    
    let centerHorizontally = NSLayoutConstraint(item: pageControl, attribute:
      .centerX, relatedBy: .equal, toItem: self,
                attribute: NSLayoutAttribute.centerX, multiplier: 1.0,
                constant: 0)
    
    
    var positionConstraint: NSLayoutConstraint?
    
    if (position == .top) {
      positionConstraint = NSLayoutConstraint(item: pageControl, attribute:
        .top, relatedBy: .equal, toItem: self,
              attribute: NSLayoutAttribute.top, multiplier: 1.0,
              constant: 25)
    } else {
      positionConstraint = NSLayoutConstraint(item: pageControl, attribute:
        .bottom, relatedBy: .equal, toItem: self,
                 attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
                 constant: -25)
    }
    
    
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([heightConstraint, centerHorizontally, positionConstraint!])
  }
  
  fileprivate func reloadData() {
    if let dataSource = dataSource {
      numberOfItems = dataSource.numberOfItems(viewPager: self)
    }
    removeViewsFromSuper()
    
    DispatchQueue.main.async {
      self.reloadScrollStepView()
    }
  }
  
  fileprivate func reloadScrollStepView() {
    setupStepControlOnReload()
    scrollView.contentSize = CGSize(width: scrollView.frame.width *  CGFloat(numberOfItems) , height:  scrollView.frame.height)
    reloadViews(index: 0)
  }
  
  fileprivate func removeViewsFromSuper() {
    itemViews.removeAll()
    
    for view in  scrollView.subviews {
      view.removeFromSuperview()
    }
  }
  
  fileprivate func setupStepControlOnReload() {
    let widthConstraint = NSLayoutConstraint(item: pageControl, attribute:
      .width, relatedBy: .equal, toItem: nil,
              attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0,
              constant: pageControlWidth)
    
    pageControl.numberOfSteps = numberOfItems
    NSLayoutConstraint.activate([widthConstraint])
    pageControl.updateLayerFrames()
  }
  
  fileprivate func loadViewAtIndex(index: Int){
    let view: UIView?
    
    view = dataSource == nil ? UIView() : dataSource!.viewAtIndex(viewPager: self, index: index, view: itemViews[index])
    
    setFrameForView(view: view!, index: index)
    itemViews[index] = view
    if (itemViews[index] == nil) {
      scrollView.addSubview(itemViews[index]!)
    }
  }
  
  fileprivate func reloadViews(index:Int) {
    for i in (index - 1)...(index + 1) {
      if (i >= 0 && i < numberOfItems){
        loadViewAtIndex(index: i)
      }
    }
  }
  
  func setFrameForView(view:UIView,index:Int) {
    view.frame = CGRect(x:  scrollView.frame.width * CGFloat(index), y: 0, width:  scrollView.frame.width, height:  scrollView.frame.height)
  }
}

extension StepControl: UIScrollViewDelegate {
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    var pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    pageNumber += 1
    pageControl.currentPage = Int(pageNumber)
    currentPosition = pageControl.currentPage
    scrollToPage(index: Int(pageNumber))
  }
  
  // Help from: http://stackoverflow.com/a/1857162
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    NSObject.cancelPreviousPerformRequests(withTarget: scrollView)
    perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.3)
  }
}

extension StepControl {
  
  public func moveToNextPage () {
    if (currentPosition <= numberOfItems && currentPosition > 0) {
      scrollToPage(index: currentPosition)
      currentPosition = currentPosition + 1
      if currentPosition > numberOfItems {
        currentPosition = 1
      }
    }
  }
  
  public func scrollToPage(index:Int) {
    if(index <= numberOfItems && index > 0) {
      let zIndex = index - 1
      let iframe = CGRect(x: scrollView.frame.width * CGFloat(zIndex), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
      scrollView.setContentOffset(iframe.origin, animated: true)
      reloadViews(index: zIndex)
      currentPosition = index
    }
  }
}
