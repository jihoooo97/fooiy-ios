import RxSwift
import RxRelay
import CoreLocation

final class SearchShopViewModel {

    // MARK: - Inputs
    let searchTextSubject = BehaviorRelay<String>(value: "")
    
    // MARK: - Outputs
    let shopListSubject = BehaviorRelay<[ShopSearchResult]>(value: [])
    let shopListTotalSubject = BehaviorRelay<Int>(value: 0)
    let noShopImageSubject = BehaviorRelay<String>(value: "")
    let hideExplainSubject = BehaviorRelay<Bool>(value: false)
    
    var offset = 1
    
    let disposeBag = DisposeBag()
    
    init() {}
    
}


extension SearchShopViewModel {

    func searchShop(keyword: String, location: CLLocation) {
        if searchTextSubject.value.count <= 0 { return }
        offset = 1
        ShopService.shared.search(type: "map", keyword: keyword, loaction: location,
                                  limit: 20, offset: 0)
            .subscribe(onSuccess: { [weak self] response in
                if response.success {
                    guard let response = response.payload else { return }
                    
                    if let shopList = response.shop_list?.results {
                        self?.noShopImageSubject.accept("")
                        self?.shopListTotalSubject.accept(response.shop_list!.total_count)
                        self?.shopListSubject.accept(shopList)
                    } else {
                        self?.noShopImageSubject.accept(response.image ?? "")
                        self?.shopListSubject.accept([])
                    }
                    
                }
            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
    
    func patchShopList(keyword: String, location: CLLocation) {
        ShopService.shared.search(type: "map", keyword: keyword, loaction: location,
                                  limit: 20, offset: offset * 20)
        .subscribe(onSuccess: { [weak self] response in
            guard let response = response.payload?.shop_list else { return }
            let shopList = response.results
            var patchShopList = self?.shopListSubject.value ?? []
            patchShopList += shopList
            self?.shopListSubject.accept(patchShopList)
            self?.offset += 1
        }, onFailure: { error in

        }).disposed(by: disposeBag)
    }
    
}
