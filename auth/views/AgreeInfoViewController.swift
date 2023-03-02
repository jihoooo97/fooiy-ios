import UIKit
import WebKit
import SnapKit
import RxSwift
import RxCocoa

final class AgreeInfoViewController: UIViewController, UIGestureRecognizerDelegate {

    lazy var navigationBar = UIView()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var safeArea = UILayoutGuide()
    
    var navigationTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = FooiyColors.G900
        label.font = FooiyFonts.SubTitle2
        return label
    }()
    
    var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        return webView
    }()
    
    var agreeUrl = ""
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        initAttributes()
        initUI()
        inputBind()
        loadWebView()
    }
    
    private func inputBind() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func loadWebView() {
        webView.uiDelegate = self
        
        let url = URL(string: agreeUrl)
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
    
}


extension AgreeInfoViewController: WKUIDelegate {
    
    private func initAttributes() { }
    
    private func initUI() {
        safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        // super view
        [navigationBar, webView]
            .forEach { view.addSubview($0) }
        
        // navigation bar
        [backButton, navigationTitle, navigationBarLine]
            .forEach { navigationBar.addSubview($0) }
        
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeArea)
            $0.height.equalTo(56)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(navigationBar)
            $0.width.height.equalTo(24)
        }
        
        navigationTitle.snp.makeConstraints {
            $0.centerX.centerY.equalTo(navigationBar)
        }
        
        navigationBarLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(navigationBar)
            $0.height.equalTo(1)
        }
        
        webView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navigationBarLine.snp.bottom)
        }
    }
    
}
