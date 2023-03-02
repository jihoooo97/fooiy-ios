import CoreLocation
import RxSwift
import RxRelay

final class SelectPhotoViewModel {

    let locationAuthRelay = PublishRelay<Bool?>()
    var address: CLLocation?
    
}


extension SelectPhotoViewModel {
    
    func setImage(image: UIImage) -> Single<UIImage> {
        return Single.create { single in
            single(.success(image))
            return Disposables.create()
        }
    }
    
    func addressExist() -> Bool {
        if address != nil { return true }
        else { return false }
    }
    
    func nextButtonClick() {
        let locationManager = LocationManager.shared.locationManager
        
        switch locationManager?.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationAuthRelay.accept(true)
        case .restricted, .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            locationAuthRelay.accept(false)
        case .denied:
            locationAuthRelay.accept(nil)
        default:
            return
        }
    }
    
}
