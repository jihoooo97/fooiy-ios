import RxSwift
import RxRelay
import CoreLocation

final class MapViewModel {

    // MARK: Inputs
    let currentCoordinateSubject = BehaviorRelay<CLLocation>(value: CLLocation(latitude: 0, longitude: 0))
    let coordinateLeftBottomSubject = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    let coordinateRightTopSubject = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    let depthSubject = BehaviorRelay<Double>(value: 4)
    let selectedFilterSubject = BehaviorRelay<ShopFilterModel>(value: ShopFilterModel())
    
    // MARK: Outputs
    let mapFilterListSubject = BehaviorRelay<FilterListPayload?>(value: nil)
    
    let shopMarkerSubject = BehaviorRelay<[ShopMarkerListResult]>(value: [])
    let regionMarkerSubject = BehaviorRelay<[ShopMarkerListRegion]>(value: [])
    let shopListSubject = BehaviorRelay<[ShopMapListResultShopInfo]>(value: [])
    let shopListTotalSubject = BehaviorRelay<Int>(value: 0)
    let shopDetailListSubject = BehaviorRelay<[FeedListItemResult]>(value: [])
    let noShopImageSubject = BehaviorRelay<String>(value: "")
    
    let disposeBag = DisposeBag()
    
    var mapZoomLevel: Double = 16
    var totalShopDetailListCount = -1
    var offset = 1
    
    init() {
        currentCoordinateSubject
//            .debounce(.milliseconds(700), scheduler: ConcurrentDispatchQueueScheduler(queue: .global()))
            .throttle(.seconds(1), latest: true, scheduler: ConcurrentDispatchQueueScheduler(queue: .global()))
            .withUnretained(self).map { $0.0 }
            .subscribe(onNext: {
                $0.setShopMarker()
                if $0.mapZoomLevel > 12 {
                    $0.setShopMapList()
                } else {
                    $0.shopListSubject.accept([])
                    $0.shopListTotalSubject.accept(0)
                }
            })
            .disposed(by: disposeBag)
        
        selectedFilterSubject
//            .debounce(.milliseconds(700), scheduler: ConcurrentDispatchQueueScheduler(queue: .global()))
            .throttle(.seconds(1), latest: true, scheduler: ConcurrentDispatchQueueScheduler(queue: .global()))
            .withUnretained(self).map { $0.0 }
            .subscribe(onNext: {
                $0.setShopMarker()
                if $0.mapZoomLevel > 12 {
                    $0.setShopMapList()
                } else {
                    $0.shopListSubject.accept([])
                    $0.shopListTotalSubject.accept(0)
                }
            })
            .disposed(by: disposeBag)
        
        getMapFilterList()
    }
}


extension MapViewModel {
    
    func setShopMarker() {
        guard let leftBottom = coordinateLeftBottomSubject.value else { return }
        guard let rightTop = coordinateRightTopSubject.value else { return }
        let depth = depthSubject.value
        let filter = selectedFilterSubject.value.getSelectedCategoryList()
        let request = ShopMarkerRequest()
        ShopService.shared.shopMarker(request: request)
            .subscribe(onSuccess: { [weak self] response in
                if response.success {
                    guard let response = response.payload else { return }
                    // marker shopList
                    if response.shopList.results != nil {
                        self?.regionMarkerSubject.accept([])
                        self?.shopMarkerSubject.accept(response.shopList.results ?? [])
                    } else {
                        self?.regionMarkerSubject.accept(response.shopList.regions ?? [])
                        self?.shopMarkerSubject.accept([])
                    }
                } else {
                    
                }
            }, onFailure: { error in
                
            }).disposed(by: disposeBag)
    }
    
    func setShopMapList() {
        guard let leftBottom = coordinateLeftBottomSubject.value else { return }
        guard let rightTop = coordinateRightTopSubject.value else { return }
        let filter = selectedFilterSubject.value.getSelectedCategoryList()
        let request = ShopMapListRequest()
        ShopService.shared.shopMapList(request: request)
            .subscribe(onSuccess: { [weak self] response in
                if response.success {
                    guard let response = response.payload else { return }
                    if let shopList = response.shopList {
                        self?.shopListTotalSubject.accept(shopList.totalCount)
                        self?.shopListSubject.accept(shopList.results)
                    } else {
                        self?.shopListSubject.accept([])
                        self?.shopListTotalSubject.accept(0)
                    }
                } else {
                    
                }
            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
    
    func patchShopMapList() {
        guard let leftBottom = coordinateLeftBottomSubject.value else { return }
        guard let rightTop = coordinateRightTopSubject.value else { return }
        let filter = selectedFilterSubject.value.getSelectedCategoryList()
        let request = ShopMapListRequest()
        ShopService.shared.shopMapList(request: request)
            .subscribe(onSuccess: { [weak self] response in
                if response.success {
                    guard let response = response.payload else { return }
                    if let shopList = response.shopList {
                        var patchShopList = self?.shopListSubject.value ?? []
                        patchShopList += shopList.results
                        self?.shopListSubject.accept(patchShopList)
                        self?.offset += 1
                    } else {
                        self?.shopListSubject.accept([])
                        self?.shopListTotalSubject.accept(0)
                    }
                } else {
                    
                }
            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
    
    func setShopDetailList(shopId: String) {
        let currentListCount = shopDetailListSubject.value.count
        
        if (currentListCount != 0 && currentListCount == totalShopDetailListCount) { return }

        FeedService.shared.getShopList(offset: currentListCount, shopID: shopId)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                let currentFeedList = self.shopDetailListSubject.value
                
                if let feedList = response.payload.feed_list {
                    let additionalFeedList = feedList.results
                    let newFeedList = currentFeedList + additionalFeedList
                    
                    if currentFeedList.count == self.totalShopDetailListCount { return }
                    
                    self.shopDetailListSubject.accept(newFeedList)
                    self.totalShopDetailListCount = feedList.total_count
                }
                //  else if let defaultImage = response.payload.image {
                //  }
                
            }, onFailure: { error in

            }).disposed(by: disposeBag)
    }
    
    func getMapFilterList() {
        ArchiveService.shared.getFilterList(type: "MAP")
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { vm, response in
                guard let response = response.payload else { return }
                vm.mapFilterListSubject.accept(response)
            }, onError: { error in

            }).disposed(by: disposeBag)
    }
    
}
