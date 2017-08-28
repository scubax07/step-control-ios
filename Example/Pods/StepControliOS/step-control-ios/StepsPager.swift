//
//  StepsPager.swift
//  StepsPager
//
//  Created by Septiyan Andika on 6/26/16.
//  Modified by Juan Pereira on 6/9/217.
//  Copyright © 2016 sailabs. All rights reserved.
//

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
            self.pageControl.selectedColor = controlBackgroundColor
            reloadData()
        }
    }

    public var controlNotSelectedColor = UIColor.gray {
        didSet {
            self.pageControl.unselectedColor = controlNotSelectedColor
            reloadData()
        }
    }

    public var position: Position = .bottom {
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
        self.addSubview(scrollView)
        self.addSubview(pageControl)

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
        self.pageControl.selectedColor = self.controlBackgroundColor
        self.pageControl.unselectedColor = self.controlNotSelectedColor
        self.pageControl.backgroundColor = UIColor.clear

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
            self.setupStepControlOnReload()
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width *  CGFloat(self.numberOfItems) , height: self.scrollView.frame.height)
            self.reloadViews(index: 0)
        }
    }

    fileprivate func removeViewsFromSuper() {
        itemViews.removeAll()

        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
    }

    fileprivate func setupStepControlOnReload() {
        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute:
            .width, relatedBy: .equal, toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0,
                    constant: pageControlWidth)

        self.pageControl.numberOfSteps = numberOfItems
        NSLayoutConstraint.activate([widthConstraint])
        self.pageControl.updateLayerFrames()
    }

    fileprivate func loadViewAtIndex(index: Int){
        let view: UIView?

        if let dataSource = dataSource {
            view =  dataSource.viewAtIndex(viewPager: self, index: index, view: itemViews[index])
        } else {
            view = UIView()
        }

        setFrameForView(view: view!, index: index)

        if (itemViews[index] == nil) {
            itemViews[index] = view
            scrollView.addSubview(itemViews[index]!)
        } else {
            itemViews[index] = view
        }
    }

    fileprivate func reloadViews(index:Int) {
        for i in (index-1)...(index+1) {
            if (i >= 0 && i < numberOfItems){
                loadViewAtIndex(index: i)
            }
        }
    }

    func setFrameForView(view:UIView,index:Int) {
        view.frame = CGRect(x: self.scrollView.frame.width*CGFloat(index), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
    }
}

extension StepControl: UIScrollViewDelegate {

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        var pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageNumber = pageNumber + 1
        pageControl.currentPage = Int(pageNumber)
        currentPosition = pageControl.currentPage
        scrollToPage(index: Int(pageNumber))
    }

    // Help from: http://stackoverflow.com/a/1857162
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: scrollView)
        self.perform(#selector(self.scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.3)
    }

}

extension StepControl {

    fileprivate func moveToNextPage () {
        if (currentPosition <= numberOfItems && currentPosition > 0) {
            scrollToPage(index: currentPosition)
            currentPosition = currentPosition + 1
            if currentPosition > numberOfItems {
                currentPosition = 1
            }
        }
    }

    fileprivate func scrollToPage(index:Int) {
        if(index <= numberOfItems && index > 0) {
            let zIndex = index - 1
            let iframe = CGRect(x: self.scrollView.frame.width*CGFloat(zIndex), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            scrollView.setContentOffset(iframe.origin, animated: true)
            reloadViews(index: zIndex)
            currentPosition = index
        }
    }

}
