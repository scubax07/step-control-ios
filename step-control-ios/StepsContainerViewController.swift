import UIKit

public protocol StepsContainerViewControllerActionable {}

public extension StepsContainerViewControllerActionable where Self: UIViewController {
  
  var nextStepDestination: UIViewController? {
    guard let container = parent as? StepsContainerViewController else { return nil }
    return container.children[container.currentPageIndex + 1]
  }
  
  func nextStepController() {
    guard let container = parent as? StepsContainerViewController else { return }
    container.nextPage()
  }
  
  func lastStepController() {
    guard let container = parent as? StepsContainerViewController else { return }
    container.lastPage()
  }
}

public class StepsContainerViewController: UIViewController {

  // MARK: Properties
  public var stepControl: StepControl = StepControl()
  private var viewSteps: [UIView] = []
  private var stepIndex: Int = 1
  
  // MARK: Interface
  public func configure(stepControl: StepControl = StepControl(), steps: UIViewController...) {
    self.stepControl = stepControl
    steps.forEach { configureStep(controller: $0) }
    
    configureStepControl()
  }
  
  public func nextPage() {
    if stepIndex < viewSteps.count {
      stepIndex += 1
      stepControl.scrollToPage(index: stepIndex)
    }
  }
  
  public func lastPage() {
    if stepIndex > 1 {
      stepIndex -= 1
      stepControl.scrollToPage(index: stepIndex)
    }
  }
  
  public var currentPageIndex: Int {
    return stepIndex - 1
  }
  
  // MARK: Private
  private func configureStepControl() {
    configureStepControlLayout()
    
    stepControl.dataSource = self
    stepControl.reloadInputViews()
  }
  
  private func configureStep(controller: UIViewController) {
    viewSteps.append(controller.view)
    addChild(controller)
    controller.didMove(toParent: self)
  }
  
  private func configureStepControlLayout() {
    stepControl.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stepControl)
    
    let constraints = [stepControl.topAnchor.constraint(equalTo: view.topAnchor),
                       stepControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                       stepControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                       stepControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
    
    NSLayoutConstraint.activate(constraints)
  }
}

// MARK: StepControlDataSource
extension StepsContainerViewController: StepControlDataSource {
  
    public func numberOfItems(viewPager: StepControl) -> Int {
    return viewSteps.count
  }
  
    public func viewAtIndex(viewPager: StepControl, index: Int, view: UIView?) -> UIView {
    return viewSteps[index]
  }
}
