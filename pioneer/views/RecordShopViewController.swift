import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RecordShopViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var scrollView = UIScrollView()
    lazy var contentView = UIStackView()
    
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
    lazy var shopCommentField = FooiyTextView()
    lazy var commentExplainView = UIView()
    lazy var commentExplainIcon = UIImageView()
    lazy var commentExplainLabel = UILabel()
    lazy var recordButton = UIButton()
    lazy var loadingView = LoadingView(type: .main)
    lazy var safeArea = UILayoutGuide()
    
    let viewModel = PioneerShopViewModel(type: "record")
    let disposeBag = DisposeBag()
    
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
        
        recordButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                guard let shopInfo = UserDefaultsManager.shopInfo else {
                    print("no image!")
                    return
                }
                guard let evaluationScore = self?.viewModel.evaluationScore.value,
                      let comment = self?.shopCommentField.text else { return }
                let request = RecordRequest()
                self?.viewModel.tryRecord(request: request)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.canPioneer
            .bind(to: recordButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isSuccess
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] success in
                let networkError = (self?.viewModel.networkError.value)!
                if success && !networkError {
                    UserDefaultsManager.shopInfo = nil
                    let completeView = FooiyRegisterCompleteViewController()
                    completeView.type = .record
                    self?.navigationController?.pushViewController(completeView, animated: true)
                }
            }).disposed(by: disposeBag)
        
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
        
        viewModel.networkError
            .subscribe(onNext: { [weak self] error in
                if error {
                    Toast.show(title: "네트워크 연결을 확인해주세요", y: (self?.recordButton.frame.maxY)! - 24)
                }
            }).disposed(by: disposeBag)
    }

    private func bindUI() {
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
        if intValue != self.beforeValue {
            self.beforeValue = intValue
            self.setupScore(value: intValue)
        }
    }
    
}


extension RecordShopViewController {
    
    private func initAttributes() { }
}

extension RecordShopViewController: UITextViewDelegate {
    
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
            $0.bottom.equalTo(recordButton.snp.top)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let fieldOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(fieldOffset, animated: true)
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "10자 이상 적어주세요"
            shopCommentField.countLabelText = "(0/500)"
            textView.textColor = FooiyColors.G200
        }
        scrollView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.equalTo(recordButton.snp.top)
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        self.viewModel.enableRecord((self.shopCommentField.text)!)
    }
}
