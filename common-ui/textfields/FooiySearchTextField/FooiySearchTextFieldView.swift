import UIKit

class FooiySearchTextFieldView: UIView {
    
    //  MARK: - 외부에서 지정할 수 있는 속성
    
    ///  필드를 비활성화 시킬 때 사용합니다.
    public var isDisabled: Bool = false {
        didSet {
            setState()
            textField.isDisabled = self.isDisabled
        }
    }
    
    ///  필드에 들어온 입력이 제대로 되었음을 알릴 때 사용합니다.
    public var isPositive: Bool = false {
        didSet {
            setState()
            textField.isPositive = self.isPositive
        }
    }
    
    ///  필드에 입력된 텍스트입니다.
    public var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    ///  필드에 나타나는 placeholder의 텍스트입니다.
    public var placeholder: String? {
        get { return textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    
    //  MARK: - 뷰
    
    ///  fieldLabel, textField, helperLabel을 담는 stackView입니다.
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = FooiyTextFieldView.Dimension.subviewSpacing
        return stackView
    }()
    
    ///  필드 중앙의 실제 입력 필드입니다.
    ///  public으로 열려있으니 delegate를 등록하거나 addTarget, endEditing 등의 메소드를 호출할 때
    ///  passwordTextField.delegate 대신 passwordTextField.textField.delegate 로 접근해주세요.
    public let textField: FooiySearchTextField = {
        let textField = FooiySearchTextField()
        textField.font = FooiyFonts.SubTitle2
        textField.keyboardType = .default
        return textField
    }()
    
    public let textFieldLine: UIView = {
        let view = UIView()
        view.backgroundColor = FooiyColors.G200
        return view
    }()
    
    
    // MARK: - 메소드
    
    public init() {
        super.init(frame: CGRect.zero)
        
        setStackView()
        setState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  stackView 내부를 세팅합니다.
    private func setStackView() {
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        stackView.addArrangedSubview(textField)
        stackView.addSubview(textFieldLine)
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(textFieldLine).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(FooiyTextField.Dimension.textFieldHeight)
        }
        
        textFieldLine.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom)
            $0.height.equalTo(2)
        }
        
    }
    
    ///  필드의 상태를 세팅합니다.
    ///  우선순위는 isDisabled > isNegative > isPositive 입니다.
    private func setState() {
        if self.isDisabled {
            textFieldLine.backgroundColor = FooiyColors.G200
            return
        }
        
        if self.isPositive {
            textFieldLine.backgroundColor = FooiyColors.G600
            return
        }
    }
    
}
