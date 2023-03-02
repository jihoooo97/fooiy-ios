import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation
import Toast_Swift

final class SetAddressViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    var naverMapView: NMFMapView?
    lazy var mapBottomLine = UIView()
    lazy var mapMarker = UIImageView()
    lazy var noAddressButton = UIButton()
    lazy var currentLocationButton = UIButton()
    lazy var addressDetailView = UIView()
    lazy var addressTitle = UILabel()
    lazy var addressString = UILabel()
    lazy var setAddressButton = UIButton()
    lazy var safeArea = UILayoutGuide()
    
    var location: CLLocation?
    
    let viewModel = SetAddressViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        initUI()
        setButtonClickEvent()
        bind()
    }
    
    private func setButtonClickEvent() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        noAddressButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                let selectShopViewController = SelectShopViewController()
                selectShopViewController.location = LocationManager.shared.currentLocation
                self?.navigationController?.pushViewController(selectShopViewController, animated: true)
            }).disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withUnretained(self).map{ $0.0 }
            .subscribe(onNext: { $0.moveToCurrentLocation() })
            .disposed(by: disposeBag)
        
        setAddressButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                let address = (self?.viewModel.addressString.value)!
                self?.viewModel.checkNearShop(address: address)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.noAddressButtonClick(location: location!)
        
        viewModel.gotoPioneer
            .bind(onNext: { [weak self] handler in
                let address = (self?.viewModel.addressString.value)!
                if handler {
                    let pioneerViewController = PioneerShopViewController()
                    pioneerViewController.address = address
                    self?.navigationController?.pushViewController(pioneerViewController, animated: true)
                } else {
                    let selectShopViewController = SelectShopViewController()
                    selectShopViewController.address = address
                    selectShopViewController.location = self?.location
                    self?.navigationController?.pushViewController(selectShopViewController, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.addressTitle
            .subscribe(on: MainScheduler.instance)
            .bind(to: addressTitle.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.addressString
            .subscribe(on: MainScheduler.instance)
            .bind(to: addressString.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.markerStateRelay
            .map { $0 ? FooiyIcons.markerEnable : FooiyIcons.markerDisable}
            .subscribe(on: MainScheduler.instance)
            .bind(to: mapMarker.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.markerStateRelay
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.setAddressButton.isEnabled = state
                if !state { Toast.show(title: "정확한 위치를 설정해주세요!", y: (self?.addressDetailView.frame.minY)! - 16) }
                else { Toast.hide() }
            }).disposed(by: disposeBag)
    }
    
}


extension SetAddressViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
    
}


extension SetAddressViewController: NMFMapViewCameraDelegate {
    
    @objc func moveToCurrentLocation() {
        let location = LocationManager.shared.currentLocation
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(from: location!.coordinate), zoomTo: 18)
        naverMapView!.moveCamera(cameraUpdate)
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        if !NetworkMonitor.shared.isConnected {
            self.showNetworkErrorAlert()
            return
        }
        let coordinate = mapView.contentBounds.center
        viewModel.getAddress(x: coordinate.lng, y: coordinate.lat)
        
        let check = viewModel.markerStateRelay.value
        viewModel.markerStateRelay.accept(check)
    }
    
}
