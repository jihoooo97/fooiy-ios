import RxSwift
import RxRelay

final class SignUpAgreeViewModel {

    let isSignup = BehaviorRelay<Bool>(value: false)
    
    let selectAllAgree = BehaviorRelay<Bool>(value: false)
    let isServiceAgree = BehaviorRelay<Bool>(value: false)
    let isLocationAgree = BehaviorRelay<Bool>(value: false)
    let isPrivacyAgree = BehaviorRelay<Bool>(value: false)
    let isFourteenAge = BehaviorRelay<Bool>(value: false)
    let isMarketingAgree = BehaviorRelay<Bool>(value: false)
    
    let isEnable = BehaviorRelay<Bool>(value: false)
    let isLoading = BehaviorRelay<Bool>(value: true)
    let networkError = BehaviorRelay<Bool>(value: false)
    
    let disposeBag = DisposeBag()
    
}


extension SignUpAgreeViewModel {
    
    func selectAgreeAll(isSelected: Bool) {
        selectAllAgree.accept(!isSelected)
        isServiceAgree.accept(!isSelected)
        isLocationAgree.accept(!isSelected)
        isPrivacyAgree.accept(!isSelected)
        isFourteenAge.accept(!isSelected)
        isMarketingAgree.accept(!isSelected)
        checkAgree()
    }
    
    func selectAgreeService(isSelected: Bool) {
        isServiceAgree.accept(!isSelected)
        checkAgree()
    }
    
    func selectAgreeLocation(isSelected: Bool) {
        isLocationAgree.accept(!isSelected)
        checkAgree()
    }
    
    func selectAgreePrivacy(isSelected: Bool) {
        isPrivacyAgree.accept(!isSelected)
        checkAgree()
    }
    
    func selectFourteen(isSelected: Bool) {
        isFourteenAge.accept(!isSelected)
        checkAgree()
    }
    
    func selectAgreeMarketing(isSelected: Bool) {
        isMarketingAgree.accept(!isSelected)
        checkAgree()
    }
    
    private func checkAgree() {
        if isServiceAgree.value && isLocationAgree.value && isPrivacyAgree.value && isFourteenAge.value {
            self.isEnable.accept(true)
        } else {
            self.isEnable.accept(false)
        }
        
        if isEnable.value && isMarketingAgree.value {
            self.selectAllAgree.accept(true)
        } else {
            self.selectAllAgree.accept(false)
        }
    }
    
    func signUpButtonClick() {
        isLoading.accept(false)
        
        let param = ProfileRequest(isMarketingAgree: isMarketingAgree.value)
        
        AccountService.shared.patchProfile(param: param)
            .subscribe(onSuccess: { [weak self] response in
                if response.success == true {
                    // AccountInfo 저장
                    guard let account = response.payload?.accountInfo else { return }
                    UserDefaultsManager.accountInfo = account
                    self?.isSignup.accept(true)
                } else {
                    // Error 처리
                }
            }, onFailure: { [weak self] error in
                self?.networkError.accept(true)
            }, onDisposed: { [weak self] in
                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 0.5,
                    execute: {
                        self?.isLoading.accept(true)
                })
            }).disposed(by: disposeBag)
    }
    
}
