import UIKit

class FooiyClearTextField: UITextField {
    
    //  MARK: - 외부에서 지정할 수 있는 속성
    
    ///  필드를 비활성화 시킬 때 사용합니다.
    internal var isDisabled: Bool = false {
        didSet {
            setState()
        }
    }
    
    ///  필드에 들어온 입력이 잘못되었음을 알릴 때 사용합니다.
    internal var isNegative: Bool = false {
        didSet { setState() }
    }
    
    ///  필드에 들어온 입력이 제대로 되었음을 알릴 때 사용합니다.
    internal var isPositive: Bool = false {
        didSet { setState() }
    }

    ///  새 값이 들어오면 setPlaceholderTextColor를 이용해
    ///  적절한 값을 가진 attributedPlaceholder로 변환합니다.
    public override var placeholder: String? {
        didSet { setPlaceholderTextColor() }
    }
    
    
    //  MARK: - 내부에서 사용되는 상수
    
    ///  clearButton의 너비입니다.
    private var clearButtonWidth: CGFloat {
        get { return clearButtonRect(forBounds: bounds).width }
    }
    
    
    //  MARK: - 메소드
    internal init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  view를 세팅합니다.
    private func setupView() {
        self.font = FooiyFonts.SubTitle2
        self.clearButtonMode = .whileEditing
        
        if let button = self.value(forKey: "_clearButton") as? UIButton {
            button.setImage(UIImage(named: "ic_clear_text"), for: .normal)
            button.tintColor = FooiyColors.G400
        }
        
        self.backgroundColor = .white
        self.snp.makeConstraints {
            $0.height.equalTo(FooiyTextField.Dimension.textFieldHeight)
        }
        
        setState()
    }
    
    ///  필드의 상태를 세팅합니다.
    ///  우선순위는 isDisabled > isNegative > isPositive 입니다.
    private func setState() {
        if isDisabled {
            self.isEnabled = false
            self.textColor = FooiyColors.G200
            return
        }
        
        if isNegative {
            self.isEnabled = true
            return
        }
        
        if isPositive {
            self.isEnabled = true
            return
        }
        
        self.isEnabled = true
        self.textColor = FooiyColors.G600
    }
    
    ///  isDisabled의 값에 따라 placeholder label의 색이 달라집니다.
    private func setPlaceholderTextColor() {
        let placeholderTextColor = FooiyColors.G200
        
        if let text = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor]
            )
        }
    }
//
//    ///  clearButton의 Bound에 관한 함수입니다.
//    ///  clearButton 우측 마진을 주기 위해 사용합니다.
//    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
//        let rect = super.clearButtonRect(forBounds: bounds)
//        return rect.offsetBy(dx: -(FooiyTextField.Dimension.rightMargin + FooiyTextField.Dimension.clearButtonDefaultRightMargin),
//                             dy: 0
//        )
//    }
//
//    ///  textRect의 Bound에 관한 함수입니다.
//    ///  placeholder label의 너비를 설정하기 위해 사용합니다.
//    public override func textRect(forBounds bounds: CGRect) -> CGRect {
//
//        return bounds.inset(by: UIEdgeInsets(top: 0,
//                                             left: FooiyTextField.Dimension.leftMargin,
//                                             bottom: 0,
//                                             right: FooiyTextField.Dimension.rightMargin + self.clearButtonWidth + FooiyTextField.Dimension.subviewSpacing
//        ))
//    }
//
//    ///  editingRect의 Bound에 관한 함수입니다.
//    ///  text label의 너비를 설정하기 위해 사용합니다.
//    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: UIEdgeInsets(top: 0,
//                                             left: FooiyTextField.Dimension.leftMargin,
//                                             bottom: 0,
//                                             right: FooiyTextField.Dimension.rightMargin + self.clearButtonWidth + FooiyTextField.Dimension.subviewSpacing
//        ))
//    }
    
}
