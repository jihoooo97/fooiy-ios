import UIKit
import SnapKit

enum FooiyTextButtonType {
    case pencil
    case arrowDown
}

class FooiyTextButton: UIButton {
    
    var textField = UITextField()
    var imageButton = UIButton()
    var textFieldEnabled: Bool = false
    var bottomBorderView = UIView()
    lazy var textButton = UIButton()
    lazy var textButtonLabel = UILabel()
    lazy var textButtonImageView = UIImageView(image: FooiyIcons.arrowDown)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    convenience init(type: FooiyTextButtonType) {
        self.init()
        
        switch type {
        case .pencil:
            // Set UI
            
        case .arrowDown:
            // Set UI
        }
    }
    
}
