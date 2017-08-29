import UIKit

struct Images {
  static let example = "example"
}

class Step: UIView {
  
  @IBOutlet weak var stepImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func addImage(image: UIImage) {
    stepImage.image = image
  }
}
