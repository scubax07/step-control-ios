//
//  StepsPager.swift
//  StepsPager
//
//  Created by Septiyan Andika on 6/26/16.
//  Modified by Juan Pereira on 6/9/217.
//  Copyright © 2016 sailabs. All rights reserved.
//

import UIKit

public protocol StepControlDataSource {
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

  public var controlBackgroundColor = Constants.Colors.selectedColor {
    didSet {
      pageControl.selectedColor = controlBackgroundColor
      reloadData()
    }
  }

  public var controlNotSelectedColor = Constants.Colors.unselectedColor {
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

  fileprivate var pageControl     = Steps()
  fileprivate var scrollView      = UIScrollView()
  fileprivate var currentPosition = 0
  fileprivate var numberOfItems   = 0
  fileprivate var itemViews       = [Int:UIView]()

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
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate(getConstraints())
  }

  fileprivate func getConstraints() -> [NSLayoutConstraint] {
    let topConstraint    = createConstraint(item: scrollView, attr1: .top, attr2: .top, multiplier: 1, constant: 0, toItem: self)
    let bottomContraints = createConstraint(item: scrollView, attr1: .bottom, attr2: .bottom, multiplier: 1, constant: 0, toItem: self)
    let leftContraints   = createConstraint(item: scrollView, attr1: .leadingMargin, attr2: .leadingMargin, multiplier: 1, constant: 0, toItem: self)
    let rightContraints  = createConstraint(item: scrollView, attr1: .trailingMargin, attr2: .trailingMargin, multiplier: 1, constant: 0, toItem: self)

    return [topConstraint, rightContraints, leftContraints, bottomContraints]
  }

  fileprivate func createConstraint(item: UIView, attr1: NSLayoutAttribute, attr2: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat, toItem: UIView?) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: item, attribute: attr1, relatedBy: .equal, toItem: toItem, attribute: attr2, multiplier: multiplier, constant: constant)
  }

  fileprivate func setupPageControl() {
    pageControl.selectedColor = controlBackgroundColor
    pageControl.unselectedColor = controlNotSelectedColor
    pageControl.backgroundColor = UIColor.clear

    setPageControlPosition()
  }

  fileprivate func setPageControlPosition() {
    let heightConstraint   = createConstraint(item: pageControl, attr1: .height, attr2: .notAnAttribute, multiplier: 1, constant: 30, toItem: nil)
    let centerHorizontally = createConstraint(item: pageControl, attr1: .centerX, attr2: .centerX, multiplier: 1, constant: 0, toItem: self)
    let positionConstraint = getPositionConstraint()

    pageControl.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([heightConstraint, centerHorizontally, positionConstraint])
  }

  fileprivate func getPositionConstraint() -> NSLayoutConstraint {
    if (position == .top) {
      return createConstraint(item: pageControl, attr1: .top, attr2: .top, multiplier: 1, constant: 25, toItem: self)
    } else {
      return createConstraint(item: pageControl, attr1: .bottom, attr2: .bottom, multiplier: 1, constant: -25, toItem: self)
    }
  }

  fileprivate func reloadData() {
    if let dataSource = dataSource {
      numberOfItems = dataSource.numberOfItems(viewPager: self)
    }

    removeViewsFromSuper()

    DispatchQueue.main.async {
      self.reloadContent()
    }
  }

  private func reloadContent() {
    setupStepControlOnReload()
    scrollView.contentSize = CGSize(width: scrollView.frame.width *  CGFloat(numberOfItems) , height: scrollView.frame.height)
    reloadViews(index: 0)
  }

  fileprivate func removeViewsFromSuper() {
    itemViews.removeAll()

    for view in scrollView.subviews {
      view.removeFromSuperview()
    }
  }

  fileprivate func setupStepControlOnReload() {
    let widthConstraint       = createConstraint(item: pageControl, attr1: .width, attr2: .notAnAttribute, multiplier: 1, constant: pageControlWidth, toItem: nil)
    pageControl.numberOfSteps = numberOfItems
    NSLayoutConstraint.activate([widthConstraint])
    pageControl.updateLayerFrames()
  }

  fileprivate func loadViewAtIndex(index: Int){
    let view = dataSource != nil ? dataSource!.viewAtIndex(viewPager: self, index: index, view: itemViews[index]) : UIView()

    setFrameForView(view: view, index: index)

    if (itemViews[index] == nil) {
      scrollView.addSubview(view)
    }

    itemViews[index] = view
  }

  fileprivate func reloadViews(index:Int) {
    for i in (index - 1)...(index + 1) {
      if (i >= 0 && i < numberOfItems){
        loadViewAtIndex(index: i)
      }
    }
  }

  func setFrameForView(view:UIView,index:Int) {
    view.frame = CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
  }
}

extension StepControl: UIScrollViewDelegate {

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    var pageNumber          = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    pageNumber              = pageNumber + 1
    pageControl.currentPage = Int(pageNumber)
    currentPosition         = pageControl.currentPage
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
      currentPosition += 1
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
