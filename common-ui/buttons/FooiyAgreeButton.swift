import UIKit

class FooiyAgreeButton: UIView {
    
    enum CheckBoxType {
        case background
        case normal
    }
    
    public var type: CheckBoxType = .normal
    
    public var font: UIFont? {
        didSet {
            buttonLabel.font = font
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            buttonLabel.textColor = textColor
        }
    }
    
    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                switch type {
                case .normal:
                    leftIcon = FooiyIcons.roundCheckBoxCheckedNavy
                case .background:
                    self.backgroundColor = FooiyColors.G600
                    textColor = .white
                    leftIcon = FooiyIcons.roundCheckBoxCheckedWhite
                }
            } else {
                switch type {
                case .background:
                    self.backgroundColor = FooiyColors.G50
                    textColor = FooiyColors.G900
                    leftIcon = FooiyIcons.roundCheckBoxDefault
                case .normal:
                    leftIcon = FooiyIcons.roundCheckBoxDefault
                }
            }
        }
    }
    
    /**
     버튼의 좌측에 들어갈 아이콘을 설정할 때 사용합니다.
     */
    public var leftIcon: UIImage? = nil {
        didSet {
            if leftIcon == nil {
                leftButton.isHidden = true
            } else {
                leftButton.image = leftIcon
            }
        }
    }
    
    /**
     버튼의 우측에 들어갈 아이콘을 설정할 때 사용합니다.
     */
    public var rightIcon: UIImage? = nil {
        didSet {
            if rightIcon == nil {
                rightButton.isHidden = true
            } else {
                rightButton.setImage(rightIcon, for: .normal)
            }
        }
    }
    
    public var buttonText: String? {
        get { return buttonLabel.text }
        set { buttonLabel.text = newValue }
    }

    public var leftButton: UIImageView = {
        let view = UIImageView()
        return view
    }()

    public var rightButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private var buttonLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func initUI() {
        [leftButton, rightButton, buttonLabel]
            .forEach { self.addSubview($0) }
        
        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        buttonLabel.snp.makeConstraints {
            $0.leading.equalTo(leftButton.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc func tap(_ sender: UIControl) {
        self.isSelected = !isSelected
    }
    
}
