import UIKit
import StepControliOS

class ViewController: UIViewController {
  
  @IBOutlet weak var stepControl: StepControl!
  var steps: [UIView] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStep()
  }
  
  func setupStep() {
    let stepOne = Bundle.main.loadNibNamed("View", owner: nil, options: nil)![0] as! Step
    let stepTwo = Bundle.main.loadNibNamed("View", owner: nil, options: nil)![0] as! Step
    stepOne.addImage(image: UIImage(named: Images.example)!)
    stepTwo.addImage(image: UIImage(named: Images.example)!)
    steps.append(stepOne)
    steps.append(stepTwo)
    stepControl.dataSource = self
    stepControl.reloadInputViews()
  }
}

extension ViewController: StepControlDataSource {
  
  func numberOfItems(viewPager: StepControl) -> Int {
    return steps.count
  }
  
  func viewAtIndex(viewPager: StepControl, index: Int, view: UIView?) -> UIView {
    return steps[index]
  }
}
