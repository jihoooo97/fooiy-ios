import RxSwift
import RxRelay

final class SelectMenuViewModel {

    let menuList = BehaviorRelay<[ShopMenuList]>(value: [])
    let networkError = BehaviorRelay<Bool>(value: false)
    
    let disposeBag = DisposeBag()
    
}


extension SelectMenuViewModel {
    
    func searchMenu(shopId: String) {
        ShopService.shared.menu(shopID: shopId)
            .subscribe(onSuccess: { response in

            }, onFailure: { [weak self] error in

            }).disposed(by: disposeBag)
    }
    
}
