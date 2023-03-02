import UIKit

class FooiyOnOffButton: UIButton {
    var onImage: UIImage?
    var offImage: UIImage?
    
    var isOn: Bool = false {
        didSet {
            if isOn {
                self.setImage(onImage, for: .normal)
            }
            else {
                self.setImage(offImage, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(onImage: UIImage, offImage: UIImage) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .white
        self.onImage = onImage
        self.offImage = offImage
        self.contentMode = .scaleAspectFit
        self.setImage(offImage, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
