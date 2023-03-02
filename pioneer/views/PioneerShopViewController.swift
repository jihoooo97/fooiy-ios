import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class PioneerShopViewController: UIViewController {
    
    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var eventBanner = UIImageView()
    lazy var scrollView = UIScrollView()
    lazy var stackView = UIStackView()
    lazy var shopNameField = FooiyClearTextFieldView()
    lazy var shopAddressField = FooiyClearTextFieldView()
    lazy var shopMenuField = FooiyClearTextFieldView()
    lazy var shopPriceField = FooiyClearTextFieldView()
    lazy var shopCommentField = FooiyTextView()
    lazy var shopNameExplainLabel = UILabel()
    lazy var shopAddressExplainLabel = UILabel()
    
    lazy var shopEvaluationField = UIStackView()
    lazy var shopEvaluationFieldText = UILabel()
    
    lazy var evaluationSliderView = UIView()
    lazy var evaluationSlider = UISlider()
    lazy var round1 = UIView()
    lazy var round2 = UIView()
    lazy var round3 = UIView()
    lazy var round4 = UIView()
    lazy var round5 = UIView()
    
    lazy var evaluationExplainView = UIView()
    lazy var evaluationExplainIcon = UIImageView()
    lazy var evaluationExplainLabel = UILabel()
    lazy var commentExplainView = UIView()
    lazy var commentExplainIcon1 = UIImageView()
    lazy var commentExplainIcon2 = UIImageView()
    lazy var commentExplainLabel1 = UILabel()
    lazy var commentExplainLabel2 = UILabel()
    lazy var pioneerButton = UIButton()
    lazy var loadingView = LoadingView(type: .main)
    lazy var safeArea = UILayoutGuide()
    
    let viewModel = PioneerShopViewModel(type: "pioneer")
    let disposeBag = DisposeBag()
    
    var shopName = ""
    var address = ""
    var beforeValue: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        initUI()
        setButtonClickEvent()
        bind()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardManager.shared.create(delegate: self)
        GatewayViewController.share?.hideTabbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardManager.shared.remove()
    }
    
    private func setButtonClickEvent() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        pioneerButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                guard let shopInfo = UserDefaultsManager.shopInfo else {
                    print("no image!")
                    return
                }
                guard let shopName = self?.shopNameField.text,
                      let address = self?.shopAddressField.text,
                      let menuName = self?.shopMenuField.text,
                      let menuPrice = self?.shopPriceField.text,
                      let evaluationScore = self?.viewModel.evaluationScore.value,
                      let comment = self?.shopCommentField.text else { return }
                let request = PioneerRequest()
                self?.viewModel.tryPioneer(request: request)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.canPioneer
            .bind(to: pioneerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isSuccess
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] success in
                let networkError = (self?.viewModel.networkError.value)!
                if success && !networkError {
                    UserDefaultsManager.shopInfo = nil
                    let completeView = FooiyRegisterCompleteViewController()
                    completeView.type = .pioneer
                    self?.navigationController?.pushViewController(completeView, animated: true)
                }
            }).disposed(by: disposeBag)
        
        shopPriceField.textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .filter { $0.count > 0 }
//            .filter { $0.filter("0123456789".contains }
            .map { [weak self] price in
                let formatPrice = price.filter("0123456789".contains)
                return (self?.decimalPrice(value: Int(formatPrice) ?? 0))!
            }
            .bind(to: shopPriceField.textField.rx.text)
            .disposed(by: disposeBag)
        
        evaluationSlider.rx.value
            .map { Int(round($0)) }
            .subscribe(onNext: { [weak self] value in
                self?.evaluationSlider.value = Float(value)
                if value != self?.beforeValue {
                    self?.beforeValue = value
                    self?.setupScore(value: value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
    }
    
    private func bindUI() {
        viewModel.bannerListSubject
            .filter { $0.count > 0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] banners in
                self?.eventBanner.kf.setImage(with: URL(string: banners[0]))
            }).disposed(by: disposeBag)
        
        viewModel.evaluationExplainSubject
            .observe(on: MainScheduler.instance)
            .bind(to: evaluationExplainLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.emogiListSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                var emogiList: [UIImage] = []
                list.forEach {
                    let url = URL(string: $0.image)
                    let data = try? Data(contentsOf: url!)
                    let image = UIImage(data: data!)!.resize(newWidth: 48)
                    emogiList.append(image)
                }
                self?.viewModel.resizeEmogiSubject.accept(emogiList)
            }).disposed(by: disposeBag)
    }
    
    private func setupScore(value: Int) { }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.evaluationSlider)

        let widthOfSlider: CGFloat = evaluationSlider.frame.size.width
        let newValue = (pointTapped.x / widthOfSlider) * 4
        
        let intValue = Int(round(newValue))
        self.evaluationSlider.value = Float(intValue)
        self.setupScore(value: intValue)
    }
    
    func decimalPrice(value: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        return result
    }
    
}


extension PioneerShopViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
    
}

extension PioneerShopViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // textField 포커싱 시 스크롤
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case shopNameField.textField:
            let fieldOffset = CGPoint(x: 0, y: shopNameField.frame.minY)
            scrollView.setContentOffset(fieldOffset, animated: true)
        case shopMenuField.textField:
            let fieldOffset = CGPoint(x: 0, y: shopMenuField.frame.minY)
            scrollView.setContentOffset(fieldOffset, animated: true)
        case shopPriceField.textField:
            let fieldOffset = CGPoint(x: 0, y: shopPriceField.frame.minY)
            scrollView.setContentOffset(fieldOffset, animated: true)
        default: return
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.viewModel.enablePioneer((self.shopNameField.text)!.count,
                                     (self.shopMenuField.text)!.count,
                                     (self.shopPriceField.text)!.count,
                                     (self.shopCommentField.text)!)
        
        if textField == shopPriceField.textField {
            if textField.text!.count > 9 {
                shopPriceField.textField.text! = String(shopPriceField.textField.text!.prefix(9))
                textField.resignFirstResponder()
            }
        }
        
        if textField == shopNameField.textField {
            if textField.text!.count > 200 {
                shopNameField.textField.text! = String(shopNameField.textField.text!.prefix(200))
                textField.resignFirstResponder()
            }
        }
        
        if textField == shopMenuField.textField {
            if textField.text!.count > 50 {
                shopMenuField.textField.text! = String(shopMenuField.textField.text!.prefix(50))
                textField.resignFirstResponder()
            }
        }
    }
    
}

extension PioneerShopViewController: UITextViewDelegate {
    
    // textView 포커싱 시 스크롤
    func textViewDidBeginEditing(_ textView: UITextView) {
        let fieldOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)
        scrollView.setContentOffset(fieldOffset, animated: true)
        
        if textView.text == "10자 이상 적어주세요" {
            textView.text = nil
            textView.textColor = FooiyColors.G600
        }
        
        scrollView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.equalTo(pioneerButton.snp.top)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "10자 이상 적어주세요"
            shopCommentField.countLabelText = "(0/500)"
            textView.textColor = FooiyColors.G200
        }
        scrollView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.equalTo(pioneerButton.snp.top)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.viewModel.enablePioneer((self.shopNameField.text)!.count,
                                     (self.shopMenuField.text)!.count,
                                     (self.shopPriceField.text)!.count,
                                     (self.shopCommentField.text)!)
    }
    
}
