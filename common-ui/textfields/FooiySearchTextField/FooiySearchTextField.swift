import UIKit

class FooiySearchTextField: UITextField {

    //  MARK: - 외부에서 지정할 수 있는 속성
    
    ///  필드를 비활성화 시킬 때 사용합니다.
    internal var isDisabled: Bool = false {
        didSet {
            setState()
            setPlaceholderTextColor()
        }
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
    
    ///  searchButton의 너비입니다.
    private var searchButtonWidth: CGFloat {
        get { return rightViewRect(forBounds: bounds).width }
    }
    
    //  MARK: - 뷰
    
    public let searchButton: UIButton = {
        let button = UIButton()
        button.size(24)
        button.setImage(FooiyIcons.search, for: .normal)
        button.tintColor = FooiyColors.G200
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    
    // MARK: - 메소드
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
        self.rightView = searchButton
        self.rightViewMode = .always
        
        self.snp.makeConstraints {
            $0.height.equalTo(FooiyTextField.Dimension.textFieldHeight)
        }
        
        self.keyboardType = .asciiCapable
        self.clearsOnBeginEditing = false
        self.clearsOnInsertion = false
        
        setState()
    }
    
    ///  필드의 상태를 세팅합니다.
    ///  우선순위는 isDisabled > isNegative > isPositive 입니다.
    private func setState() {
        if isDisabled {
            self.isEnabled = false
            self.textColor = FooiyColors.G200
            searchButton.tintColor = FooiyColors.G200
            return
        }
        
        if isPositive {
            self.isEnabled = true
            self.textColor = FooiyColors.G600
            searchButton.tintColor = FooiyColors.G600
            return
        }
        
        self.isEnabled = true
        self.textColor = FooiyColors.G600
    }
    
    ///  isDisabled의 값에 따라 placeholder label의 색이 달라집니다.
    private func setPlaceholderTextColor() {
        let placeholderTextColor: UIColor = FooiyColors.G200
        
        if let text = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: text,
                attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor]
            )
        }
    }
    
    ///  rightView의 Bound에 관한 함수입니다.
    ///  maskingButton의 너비를 설정하기 위해 사용합니다.
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return rect.offsetBy(dx: 0, dy: 0)
    }
    
}
