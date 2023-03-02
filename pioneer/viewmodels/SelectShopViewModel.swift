import RxSwift
import RxRelay
import CoreLocation

final class SelectShopViewModel {

    // MARK: - Inputs
    let searchString = BehaviorSubject<String>(value: "")
    
    // MARK: - Outputs
    let shopListSubject = BehaviorRelay<[ShopSearchResult]>(value: [])
    
    let disposeBag = DisposeBag()
    
}


extension SelectShopViewModel {
    
    func searchShop(keyword: String, location: CLLocation) {
        if keyword.count == 0 { return }
        ShopService.shared.search(type: "register_feed", keyword: keyword, loaction: location,
                                  limit: nil, offset: nil)
            .subscribe(onSuccess: { [weak self] response in

            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
    
    func nearbyShop(address: String) {
        if address == "" { return }
        ShopService.shared.nearby(address: address)
            .subscribe(onSuccess: { [weak self] response in

            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
}
