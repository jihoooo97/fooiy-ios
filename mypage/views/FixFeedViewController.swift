import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol FixFeedViewControllerDelegate: NSObjectProtocol {
    func updateFeed(feedId: String, evaluation: String, comment: String)
}

class FixFeedViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var scrollView = UIScrollView()
    lazy var stackView = UIStackView()
    lazy var shopCommentField = FooiyTextView()
    
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
    lazy var commentExplainIcon = UIImageView()
    lazy var commentExplainLabel = UILabel()
    lazy var fixButton = UIButton()
    lazy var loadingView = LoadingView(type: .main)
    lazy var safeArea = UILayoutGuide()
    
    var feedId: String?
    var feedEvaluationImageUrl: String?
    var feedComment: String?
    var beforeValue: Int = -1
    var url: String = ""
    
    let viewModel = FixFeedViewModel(type: "record")
    let disposeBag = DisposeBag()
    
    weak var delegate: FixFeedViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initAttributes()
        initUI()
        bindUI()
        inputBind()
        outputBind()
    }
    
    private func inputBind() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        fixButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let evaluationScore = self?.viewModel.evaluationScore.value,
                      let comment = self?.shopCommentField.text else { return }
                let request = ModifyRequest()
                self?.viewModel.tryFix(request: request)
            }).disposed(by: disposeBag)
    }

    private func outputBind() {
        evaluationSlider.rx.value
            .map { Int(round($0)) }
            .subscribe(onNext: { [weak self] value in
                self?.evaluationSlider.value = Float(value)
                if value != self?.beforeValue {
                    self?.beforeValue = value
                    self?.setupScore(value: value)
                }
            }).disposed(by: disposeBag)
        
        viewModel.canFix
            .bind(to: fixButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isSuccess
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] success in
                let networkError = (self?.viewModel.networkError.value)!
                if success && !networkError {
                    UserDefaultsManager.shopInfo = nil
                    let completeView = FooiyRegisterCompleteViewController()
                    completeView.type = .modify
                    self?.setDelegate()
                    self?.navigationController?.pushViewController(completeView, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setDelegate() {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
    }
    
    func bindUI() {
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
                self?.defaultEvaluation()
            }).disposed(by: disposeBag)
    }
    
    func defaultEvaluation() {
        guard let evaluationImageUrl = feedEvaluationImageUrl else { return }
        
        viewModel.emogiListSubject.value
            .enumerated().forEach { [weak self] in
                if evaluationImageUrl == $0.element.image {
                    let sliderImage = viewModel.resizeEmogiSubject.value[$0.offset]
                    evaluationSlider.setThumbImage(sliderImage, for: .normal)
                    evaluationSlider.value = Float($0.offset)
                    viewModel.evaluationScore.accept($0.element.score)
                    self?.setupScore(value: $0.offset)
                }
            }
    }
    
    private func setupScore(value: Int) {
        let emogiList = viewModel.emogiListSubject.value
        let resizeEmogiList = viewModel.resizeEmogiSubject.value
        if emogiList.count > 0 {
            evaluationSlider.setThumbImage(resizeEmogiList[value], for: .normal)
            viewModel.evaluationScore.accept(emogiList[value].score)
            url = emogiList[value].image
        }
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.evaluationSlider)

        let widthOfSlider: CGFloat = evaluationSlider.frame.size.width
        let newValue = (pointTapped.x / widthOfSlider) * 4
        
        let intValue = Int(round(newValue))
        self.evaluationSlider.value = Float(intValue)
        self.setupScore(value: intValue)
    }
    
}


extension FixFeedViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
        
}
