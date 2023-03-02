import RxSwift
import RxRelay
import CoreLocation

final class SetAddressViewModel {

    let addressTitle = BehaviorRelay<String>(value: "")
    let addressString = BehaviorRelay<String>(value: "")
    let currentAddressRelay = BehaviorRelay<String>(value: "")
    let markerStateRelay = BehaviorRelay<Bool>(value: false)
    let gotoPioneer = PublishRelay<Bool>()
    
    let disposeBag = DisposeBag()
    
}


extension SetAddressViewModel {
    
    func getAddress(x: Double, y: Double) {
        MapService.shared.getAddress(x: x, y: y)
            .subscribe(onSuccess: { [weak self] address in

            }).disposed(by: disposeBag)
    }
    
    func noAddressButtonClick(location: CLLocation) {
        let x = location.coordinate.longitude
        let y = location.coordinate.latitude
        
        MapService.shared.getAddress(x: x, y: y)
            .subscribe(onSuccess: { [weak self] response in

            }).disposed(by: disposeBag)
    }
    
    func checkNearShop(address: String) {
        ShopService.shared.nearby(address: address)
            .subscribe(onSuccess: { [weak self] response in

            }).disposed(by: disposeBag)
    }
    
}
