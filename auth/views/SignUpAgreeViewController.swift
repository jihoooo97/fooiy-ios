import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Lottie

final class SignUpAgreeViewController: UIViewController {

    lazy var scrollView = UIScrollView()
    lazy var contentView = UIView()
    lazy var fooiyAgreeLabel = UILabel()
    lazy var agreeExplainLabel = UILabel()
    lazy var agreeAllButton = FooiyAgreeButton()
    lazy var agreeServiceButton = FooiyAgreeButton()
    lazy var agreeLocationButton = FooiyAgreeButton()
    lazy var agreePrivacyButton = FooiyAgreeButton()
    lazy var ageFourteenButton = FooiyAgreeButton()
    lazy var agreeMarketingButton = FooiyAgreeButton()
    lazy var agreeMarketingLabel = UILabel()
    lazy var signUpButton = UIButton()
    lazy var loadingView = LoadingView(type: .main)
    lazy var safeArea = UILayoutGuide()
    
    let viewModel = SignUpAgreeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        initUI()
        setButtonClickEvent()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func setButtonClickEvent() {
        agreeServiceButton.rightButton.rx.tap
            .bind(onNext: { [weak self] in
                let agreeView = AgreeInfoViewController()
                agreeView.navigationTitle.text = "서비스 이용약관"
                agreeView.agreeUrl = ""
                self?.navigationController?.pushViewController(agreeView, animated: true)
            }).disposed(by: disposeBag)
        
        agreeLocationButton.rightButton.rx.tap
            .bind(onNext: { [weak self] in
                let agreeView = AgreeInfoViewController()
                agreeView.navigationTitle.text = "위치기반 이용약관"
                agreeView.agreeUrl = ""
                self?.navigationController?.pushViewController(agreeView, animated: true)
            }).disposed(by: disposeBag)
        
        agreePrivacyButton.rightButton.rx.tap
            .bind(onNext: { [weak self] in
                let agreeView = AgreeInfoViewController()
                agreeView.navigationTitle.text = "개인정보 수집 및 이용"
                agreeView.agreeUrl = ""
                self?.navigationController?.pushViewController(agreeView, animated: true)
            }).disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                self?.viewModel.signUpButtonClick()
            }).disposed(by: disposeBag)
    }
    
    // #MARK: binding
    private func bind() {
        viewModel.isSignup
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSignup in
                // 약관 동의 페이지를 왔으면 푸이티아이가 무조건 없으므로 검사
                if isSignup {
                    self?.navigationController?.pushViewController(FooiytiCheckViewController(), animated: true)
                } else {
                    
                }
            }).disposed(by: disposeBag)
        
        viewModel.selectAllAgree
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.agreeAllButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isServiceAgree
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.agreeServiceButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isLocationAgree
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.agreeLocationButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isPrivacyAgree
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.agreePrivacyButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isFourteenAge
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.ageFourteenButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isMarketingAgree
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.agreeMarketingButton.isSelected = isSelected
            }).disposed(by: disposeBag)
        
        viewModel.isEnable
            .observe(on: MainScheduler.instance)
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(on: MainScheduler.instance)
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.networkError
            .subscribe(onNext: { [weak self] error in
                if error {
                    Toast.show(title: "네트워크 연결을 확인해주세요", y: (self?.signUpButton.frame.minY)! - 24)
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func selectAgreeAll() {
        self.viewModel.selectAgreeAll(isSelected: self.agreeAllButton.isSelected)
    }
    
    @objc func selectAgreeService() {
        self.viewModel.selectAgreeService(isSelected: self.agreeServiceButton.isSelected)
    }
    
    @objc func selectAgreeLocation() {
        self.viewModel.selectAgreeLocation(isSelected: self.agreeLocationButton.isSelected)
    }
    
    @objc func selectAgreePrivacy() {
        self.viewModel.selectAgreePrivacy(isSelected: self.agreePrivacyButton.isSelected)
    }
    
    @objc func selectFourteen() {
        self.viewModel.selectFourteen(isSelected: self.ageFourteenButton.isSelected)
    }
    
    @objc func selectAgreeMarketing() {
        self.viewModel.selectAgreeMarketing(isSelected: self.agreeMarketingButton.isSelected)
    }
    
}


extension SignUpAgreeViewController {
    
    // #MARK: view 요소 속성
    private func initAttributes() { }
    
    // #MARK: 레이아웃
    private func initUI() { }
    
}
