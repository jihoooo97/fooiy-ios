import UIKit

class FooiyCategoryLabel: UILabel {

    private var padding = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.padding = padding
        self.textAlignment = .center
        self.text = ""
        self.textColor = FooiyColors.P500
        self.font = FooiyFonts.Caption1b
        self.layer.borderWidth = 1
        self.layer.borderColor = FooiyColors.P500.cgColor
        self.layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
