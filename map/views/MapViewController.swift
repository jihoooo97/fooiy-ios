import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation

final class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    struct SelectedShop {
        weak var marker: NMFMarker?
        weak var data: ShopMarkerListResult?
        var lat: String?
        var lng: String?
        
        mutating func save(marker: NMFMarker?, data: ShopMarkerListResult?) {
            self.marker = marker
            self.data = data
            self.lat = data?.latitude
            self.lng = data?.longitude
        }
        
        mutating func reset() {
            self.marker = nil
            self.data = nil
            self.lat = data?.latitude
            self.lng = data?.longitude
        }
    }
    
    var naverMapView: NMFMapView?
    lazy var searchBar = UIView()
    lazy var searchIcon = UIImageView()
    lazy var searchLabel = UILabel()
    lazy var filterButton = UIButton()
    lazy var currentLocationButton = UIButton()
    lazy var multiShopView = MultiShopView(shopList: [])
    lazy var bottomModal = BottomSheetView()
    lazy var safeArea = UILayoutGuide()
    
    let markerBase = FooiyMapMarker(
    let regionMarkerBase = FooiyRegionMarker()
    var markersInMap: [NMFMarker?] = []
    
    let viewModel = MapViewModel()
    let disposeBag = DisposeBag()
    
    var selectedShop = SelectedShop()
    var paging = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        initUI()
        inputBind()
        outputBind()
    }
    
    private func inputBind() {
        bottomModal.shopListTableView.rx.itemSelected
            .withUnretained(self).map { $0 }
            .subscribe(onNext: { [weak self] vc, indexPath in
                let item = vc.viewModel.shopListSubject.value[indexPath.row]
                vc.viewModel.setShopDetailList(shopId: item.publicId)
                let shopDetailViewController = ShopDetailViewController()
                shopDetailViewController.shopName = item.name
                shopDetailViewController.delegate = self
                shopDetailViewController.viewModel = vc.setShopViewModel(id: item.publicId)
                self?.navigationController?.pushViewController(shopDetailViewController, animated: true)
            }).disposed(by: disposeBag)
        
        multiShopView.shopViewContainer!.rx.itemSelected
            .withUnretained(self).map { $0 }
            .subscribe(onNext: { [weak self] vc, indexPath in
                guard let selectedShop = vc.selectedShop.data else { return }
                let item = selectedShop.shopsInfo[indexPath.row]
                vc.viewModel.setShopDetailList(shopId: item.publicId)
                let shopDetailViewController = ShopDetailViewController()
                shopDetailViewController.shopName = item.name
                shopDetailViewController.delegate = self
                shopDetailViewController.viewModel = vc.setShopViewModel(id: item.publicId)
                self?.navigationController?.pushViewController(shopDetailViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func outputBind() {
        // marker
        viewModel.shopMarkerSubject
            .asObservable()
            .withUnretained(self)
            .map { $0.0 }
            .subscribe(onNext: { $0.makeShopMarkers() })
            .disposed(by: disposeBag)
                  
        // shopList
        viewModel.shopListSubject
            .filter { $0.count >= 0 }
            .observe(on: MainScheduler.instance)
            .bind(to: bottomModal.shopListTableView.rx.items(
                cellIdentifier: FooiyShopCell.cellId,
                cellType: FooiyShopCell.self)) { index, item, cell in
                    cell.setData(shopInfo: item)
                }.disposed(by: disposeBag)
        
        viewModel.shopListSubject
            .bind(onNext: { [weak self] shopList in
                let shopTotal = self?.viewModel.shopListTotalSubject.value ?? 0
                if shopList.count < shopTotal {
                    self?.paging = true
                } else {
                    self?.paging = false
                }
            }).disposed(by: disposeBag)
        
        bottomModal.shopListTableView.rx.didScroll
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let shopTotal = self.viewModel.shopListTotalSubject.value
                
                if shopTotal <= 20 { return }
                let offsetY = self.bottomModal.shopListTableView.contentOffset.y
                let contentHeight = self.bottomModal.shopListTableView.contentSize.height
                let paginationY = self.bottomModal.shopListTableView.frame.size.height
                
                if offsetY > (contentHeight - paginationY - 1360) && self.paging {
                    self.paging = false
                    self.viewModel.patchShopMapList()
                }
            }).disposed(by: disposeBag)
        
        // bottomModal background hidden
        viewModel.shopListSubject
            .observe(on: MainScheduler.instance)
            .map { $0.count > 0 }
            .bind(to: bottomModal.rx.backgroundHidden)
            .disposed(by: disposeBag)
        
        viewModel.depthSubject
            .observe(on: MainScheduler.instance)
            .map { $0 < 4 }
            .bind(onNext: { [weak self] showLabel in
                self?.bottomModal.shopListTableView.isHidden = showLabel
                self?.bottomModal.zoomLevelOutLabel.isHidden = !showLabel
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Draw
    private func deleteOldMarkers() {
        guard naverMapView != nil else { return }
        let markerList = viewModel.shopMarkerSubject.value
//        let regionList = viewModel.regionMarkerSubject.value
        
        DispatchQueue.main.async { [weak self] in
            self?.markersInMap.forEach { $0?.mapView = nil }
            self?.markersInMap.removeAll()
            if markerList.count == 0 {
                self?.selectedShop.marker = nil
            }
        }
    }
    
    private func makeShopMarkers() {
        let value = viewModel.shopMarkerSubject.value
        let regionValue = viewModel.regionMarkerSubject.value
        
        deleteOldMarkers()
        value.forEach { [weak self] shopData in
            let marker = (self?.markerBase)!
            self?.drawShopMarkerInMap(markerInfo: shopData, shopMarker: marker)
        }
        
        regionValue.forEach { [weak self] regionData in
            let marker = (self?.regionMarkerBase)!
            self?.drawRegionMarkerInMap(markerInfo: regionData, shopMarker: marker)
        }
        
    }
    
    func drawShopMarkerInMap(markerInfo: ShopMarkerListResult, shopMarker: FooiyMapMarker) {
        guard let lat = Double(markerInfo.latitude),
              let lng = Double(markerInfo.longitude) else { return }
        
        let position = NMGLatLng(lat: lat, lng: lng)
        let marker = NMFMarker(position: position)
        let isSelected = (selectedShop.lat == markerInfo.latitude && selectedShop.lng == markerInfo.longitude)
        
        marker.touchHandler = { [weak self] touchMarker -> Bool in
            self?.switchShopSelectedMarker(isNew: false)
            self?.selectedShop.save(marker: marker, data: markerInfo)
            self?.switchShopSelectedMarker(isNew: true)
            self?.setShopDetail(markerInfo: markerInfo)
            return true
        }
        
        DispatchQueue.main.async { [weak self] in
            if isSelected {
                self?.switchShopSelectedMarker(isNew: false)
                self?.selectedShop.save(marker: marker, data: markerInfo)
                self?.switchShopSelectedMarker(isNew: true)
            } else {
                shopMarker.isPressed = isSelected
                shopMarker.setData(markerInfo: markerInfo)
                marker.iconImage = NMFOverlayImage(image: shopMarker.asImage())
            }
            
            marker.mapView = self?.naverMapView
            self?.markersInMap.append(marker)
        }
    }
    
    func drawRegionMarkerInMap(markerInfo: ShopMarkerListRegion, shopMarker: FooiyRegionMarker) {
        guard let lat = Double(markerInfo.latitude),
              let lng = Double(markerInfo.longitude) else { return }
        
        let position = NMGLatLng(lat: lat, lng: lng)
        let marker = NMFMarker(position: position)
        
        marker.touchHandler = { [weak self] touchMarker -> Bool in
            let latitude = Double(markerInfo.latitude) ?? 0
            let longitude = Double(markerInfo.longitude) ?? 0
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            var zoom: Double = 13
            if self?.viewModel.depthSubject.value == 1 {
                zoom = 9
            } else {
                zoom = 13
            }
            let camera = NMFCameraUpdate(scrollTo: NMGLatLng(from: location), zoomTo: zoom)
            camera.animation = .fly
            camera.animationDuration = 1
            self?.naverMapView?.moveCamera(camera)
            return true
        }
        
        DispatchQueue.main.async { [weak self] in
            shopMarker.setData(markerInfo: markerInfo)
            marker.iconImage = NMFOverlayImage(image: shopMarker.asImage())
            
            marker.mapView = self?.naverMapView
            self?.markersInMap.append(marker)
        }
    }
    
    func switchShopSelectedMarker(isNew : Bool) {
        guard let marker = selectedShop.marker,
              let shopData = selectedShop.data else { return }

        let shopMarker = self.markerBase
        shopMarker.isPressed = isNew
        shopMarker.setData(markerInfo: shopData)
        marker.zIndex = isNew ? 1 : 0
        marker.iconImage = NMFOverlayImage(image: shopMarker.asImage())
        self.multiShopView.shopViewContainer?.setContentOffset(CGPoint(x: -16, y: 0), animated: false)
        showShopView()
    }
    
    private func setShopDetail(markerInfo: ShopMarkerListResult) { }
    
    private func showShopView() { }
    
    private func hideShopView() { }

}


extension MapViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
    
}


// MARK: - FilterView Delegate
extension MapViewController: ShopFilterViewControllerDelegate {
    
    func setFilter(filter: ShopFilterModel) {
        if let coordinate = filter.location?.coordinate {
            hideShopView()
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(from: coordinate), zoomTo: 16)
            naverMapView?.moveCamera(cameraUpdate)
        }
        viewModel.selectedFilterSubject.accept(filter)
    }
    
}

extension MapViewController: ShopDetailProtocol {
    
    func setShopViewModel(id: String) -> ShopDetailViewModel {
        let viewModel = ShopDetailViewModel(shopID: id)
        return viewModel
    }
    
}

extension MapViewController: NMFMapViewCameraDelegate {

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        paging = true
        viewModel.offset = 1
        bottomModal.shopListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        let coordinate = mapView.cameraPosition.target
        
        let coordinateLeftBottom = mapView.contentBounds.southWest
        let leftBottom = CLLocationCoordinate2D(latitude: coordinateLeftBottom.lat, longitude: coordinateLeftBottom.lng)
        
        let coordinateRightTop = mapView.contentBounds.northEast
        let rightTop = CLLocationCoordinate2D(latitude: coordinateRightTop.lat, longitude: coordinateRightTop.lng)
        
        if naverMapView != nil {
            viewModel.mapZoomLevel = naverMapView!.zoomLevel
            if naverMapView!.zoomLevel <= 8 {
                viewModel.depthSubject.accept(1)
            } else if naverMapView!.zoomLevel <= 12 {
                viewModel.depthSubject.accept(2)
            } else {
                viewModel.depthSubject.accept(4)
            }
        }
        
        viewModel.coordinateLeftBottomSubject
            .accept(leftBottom)
        
        viewModel.coordinateRightTopSubject
            .accept(rightTop)
        
        viewModel.currentCoordinateSubject
            .accept(CLLocation(latitude: coordinate.lat, longitude: coordinate.lng))
    }
    
}

extension MapViewController: NMFMapViewTouchDelegate {

    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        self.switchShopSelectedMarker(isNew: false)
        self.selectedShop.reset()
        self.hideShopView()
    }

}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
}
