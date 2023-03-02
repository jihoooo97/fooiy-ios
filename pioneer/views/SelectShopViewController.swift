import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

final class SelectShopViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var searchTextField = FooiySearchTextFieldView()
    lazy var searchTextBottomLabel = UILabel()
    lazy var noShopButton = UIButton()
    lazy var shopList = UITableView()
    lazy var safeArea = UILayoutGuide()
    
    let viewModel = SelectShopViewModel()
    let disposeBag = DisposeBag()
    
    var location: CLLocation?
    var address = ""
    
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
        
        searchTextField.textField.searchButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                let keyword = self?.searchTextField.textField.text ?? ""
                let location = LocationManager.shared.currentLocation
                self?.viewModel.searchShop(keyword: keyword, location: location!)
                self?.searchTextField.textField.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        shopList.rx.itemSelected
            .withUnretained(self).map { $0 }
            .subscribe(onNext: { vc, indexPath in
                if !NetworkMonitor.shared.isConnected {
                    vc.showNetworkErrorAlert()
                    return
                }
                let item = vc.viewModel.shopListSubject.value[indexPath.row]
                let selectMenuViewController = SelectMenuViewController()
                selectMenuViewController.shopName = item.name
                selectMenuViewController.address = item.address
                selectMenuViewController.shopId = item.publicId
                vc.navigationController?.pushViewController(selectMenuViewController, animated: true)
            }).disposed(by: disposeBag)
        
        
        noShopButton.rx.tap
            .bind(onNext: { [weak self] in
                let pioneerShopViewController = PioneerShopViewController()
                pioneerShopViewController.address = (self?.address)!
                self?.navigationController?.pushViewController(pioneerShopViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.nearbyShop(address: address)
        
        searchTextField.textField.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchString)
            .disposed(by: disposeBag)
    
        viewModel.shopListSubject
            .observe(on: MainScheduler.instance)
            .bind(to: shopList.rx.items(
                cellIdentifier: FooiyCell.cellId,
                cellType: FooiyCell.self)
            ) { index, item, cell in
                cell.bigLabel.text = item.name
                cell.smallLabel.text = item.address
            }.disposed(by: disposeBag)
                
        // editing 시 밑줄 색
        viewModel.searchString
            .map { $0.isEmpty ? FooiyColors.G200 : FooiyColors.G400 }
            .bind(to: searchTextField.textFieldLine.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        viewModel.searchString
            .map { $0.isEmpty ? FooiyColors.G200 : FooiyColors.G400 }
            .bind(to: searchTextField.textField.searchButton.rx.tintColor)
            .disposed(by: disposeBag)
    }
    
}



extension SelectShopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: 키보드 버튼 검색
extension SelectShopViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !NetworkMonitor.shared.isConnected {
            showNetworkErrorAlert()
            return true
        }
        if textField == searchTextField.textField  && textField.text!.count > 0  {
            self.viewModel.searchShop(keyword: textField.text!, location: location!)
        }
        textField.resignFirstResponder()
        return true
    }
}


extension SelectShopViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalIndicator = scrollView.subviews[(scrollView.subviews.count - 1)].subviews[0]
        verticalIndicator.backgroundColor = FooiyColors.G100
    }
    
}

extension SelectShopViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
    
}
