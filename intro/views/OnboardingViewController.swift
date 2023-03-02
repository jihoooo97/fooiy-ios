import UIKit
import SnapKit
import RxSwift
import RxCocoa
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

final class OnboardingViewController: UIViewController {
    
    lazy var imageLayoutView = UIView()
    lazy var imageScrollView = UIScrollView()
    lazy var pageControl = UIPageControl()
    lazy var kakaoLoginButton = UIButton()
    lazy var appleLoginButton = UIButton()
    lazy var safeArea = UILayoutGuide()
    
    let sceneDelegate = SceneDelegate()
    let viewModel = OnboardingViewModel()
    var disposeBag: DisposeBag = DisposeBag()
    
    var currentPage: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttirbute()
        initUI()
        inputBind()
        outputBind()
    }
    
    private func inputBind() {
        kakaoLoginButton.rx.tap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.requestKakaoAuthorization()
            })
            .disposed(by: disposeBag)
        
        appleLoginButton.rx.tap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if #available(iOS 13.0, *) {
                    self?.requestAppleAuthorization()
                }
            })
            .disposed(by: disposeBag)
    }

    private func outputBind() {
        viewModel.onboardingImageList
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageList in
                let width = (self?.view.frame.width)!
                let height = (self?.imageScrollView.frame.height)!
                imageList.enumerated()
                    .forEach {
                        let url = URL(string: $0.element)
                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFit
                        imageView.kf.setImage(with: url)
                        let xOffset = (width - 32) * CGFloat($0.offset) - 16
                        imageView.frame = CGRect(x: xOffset, y: 0, width: width, height: height)
                        self?.imageScrollView.addSubview(imageView)
                    }
                self?.imageScrollView.contentSize.width = (width - 32) * CGFloat(imageList.count)
                self?.pageControl.numberOfPages = imageList.count
            }).disposed(by: disposeBag)
        
        viewModel.checkInfo
            .subscribe(onNext: { [weak self] info in
                switch info {
                case "main":
                    let gatewayViewController = GatewayViewController()
                    self?.navigationController?.pushViewController(gatewayViewController, animated: true)
                case "fooiyti":
                    let fooiytiViewController = FooiytiCheckViewController()
                    self?.navigationController?.pushViewController(fooiytiViewController, animated: true)
                case "agree":
                    let agreeViewController = SignUpAgreeViewController()
                    self?.navigationController?.pushViewController(agreeViewController, animated: true)
                default: return
                }
            }).disposed(by: disposeBag)
    }
    
}


// MARK: - about UI
extension OnboardingViewController {
    
    private func initAttirbute() {}
    
    private func initUI() {}
    
}

extension OnboardingViewController {
    
    private func requestKakaoAuthorization() {
        // 카카오톡 설치 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    UserApi.shared.me { user, error in
                        if let kakaoId = user?.id {
                            self?.viewModel.kakaoId.accept(String(kakaoId))
                        }
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    UserApi.shared.me { user, error in
                        if let kakaoId = user?.id {
                            self?.viewModel.kakaoId.accept(String(kakaoId))
                        }
                    }
                }
            }
        }
    }
    
}

@available(iOS 13.0, *)
extension OnboardingViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func requestAppleAuthorization() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
              
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let appleId = appleIDCredential.user
            self.viewModel.appleId.accept(appleId)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // handle Error.
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offSet = targetContentOffset.pointee
        let page = round((offSet.x + 16) / imageScrollView.frame.width)
        
        if page > currentPage {
            currentPage += 1
        } else if page < currentPage {
            if currentPage != 0 {
                currentPage -= 1
            }
        }
        self.pageControl.currentPage = Int(page)
    }
    
}
