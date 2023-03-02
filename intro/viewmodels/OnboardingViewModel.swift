import RxSwift
import RxCocoa
import RxRelay

final class OnboardingViewModel {
    
    let onboardingImageList = BehaviorRelay<[String]>(value: [])
    let kakaoId = BehaviorRelay<String?>(value: nil)
    let appleId = BehaviorRelay<String?>(value: nil)
    let checkInfo = BehaviorRelay<String>(value: "")
    
    let deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
    
    let disposeBag = DisposeBag()
    
    init() {
        ArchiveService.shared.getOnboardingImage()
            .subscribe(onSuccess: { [weak self] response in
                if let response = response.payload {
                    self?.onboardingImageList.accept(response.imageList)
                }
            }, onFailure: { error in
                
            }).disposed(by: disposeBag)
        
        kakaoId
            .subscribe(onNext: { [weak self] id in
                guard let id = id else { return }
                self?.kakaoLogin(id: id)
            }).disposed(by: disposeBag)
        
        appleId
            .subscribe(onNext: { [weak self] id in
                guard let id = id else { return }
                self?.appleLogin(id: id)
            }).disposed(by: disposeBag)
    }
    
}


extension OnboardingViewModel {
    
    private func kakaoLogin(id: String) {
        let fcmToken = UserDefaultsManager.fcmToken ?? "FCMToken Bug"
        let request = KakaoLoginRequest(socialId: id,
                                        deviceId: deviceId,
                                        appVersion: FooiyUtils.getAppVersion(),
                                        fcmToken: fcmToken)
        AccountService.shared.kakaoLogin(param: request)
            .subscribe(onSuccess: { [weak self] response in
                if let response = response.payload {
                    UserDefaultsManager.loginType = "kakao"
                    let accountInfo = response.account_info
                    UserDefaultsManager.accountInfo = accountInfo
                    
                    // agree가 nil이 아니면
                    if accountInfo.is_mkt_agree != nil {
                        // fooiyti가 있으면 메인
                        if accountInfo.fooiyti != nil {
                            self?.checkInfo.accept("main")
                        }
                        // fooiyti가 없으면 검사
                        else {
                            self?.checkInfo.accept("fooiyti")
                        }
                    }
                    // agree가 nil이면 회원가입 약관 동의
                    else {
                        self?.checkInfo.accept("agree")
                    }
                }
            }, onFailure: {  error in
                // network error or server error
            }).disposed(by: disposeBag)
    }
    
    private func appleLogin(id: String) {
        let fcmToken = UserDefaultsManager.fcmToken ?? "FCMToken Bug"
        let request = AppleLoginRequest(socialId: id,
                                        deviceId: deviceId,
                                        appVersion: FooiyUtils.getAppVersion(),
                                        fcmToken: fcmToken)
        AccountService.shared.appleLogin(param: request)
            .subscribe(onSuccess: { [weak self] response in
                if let response = response.payload {
                    UserDefaultsManager.loginType = "apple"
                    let accountInfo = response.account_info
                    UserDefaultsManager.accountInfo = accountInfo
                    
                    // agree가 nil이 아니면
                    if accountInfo.is_mkt_agree != nil {
                        // fooiyti가 있으면 메인
                        if accountInfo.fooiyti != nil {
                            self?.checkInfo.accept("main")
                        }
                        // fooiyti가 없으면 검사
                        else {
                            self?.checkInfo.accept("fooiyti")
                        }
                    }
                    // agree가 nil이면 회원가입 약관 동의
                    else {
                        self?.checkInfo.accept("agree")
                    }
                }
            }, onFailure: { error in
                // network error or server error
            }).disposed(by: disposeBag)
    }
    
}
