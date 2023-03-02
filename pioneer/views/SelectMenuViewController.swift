import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SelectMenuViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var noMenuLabel = UILabel()
    lazy var menuList = UITableView()
    lazy var noMenuButton = UIButton()
    lazy var safeArea = UILayoutGuide()
    
    let viewModel = SelectMenuViewModel()
    let disposeBag = DisposeBag()
    
    var shopName = ""
    var address = ""
    var shopId = ""
    
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
        
        noMenuButton.rx.tap
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                let pioneerViewController = PioneerShopViewController()
                pioneerViewController.shopName = (self?.shopName)!
                pioneerViewController.address = (self?.address)!
                self?.navigationController?.pushViewController(pioneerViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        viewModel.searchMenu(shopId: shopId)
        
        viewModel.menuList
            .observe(on: MainScheduler.instance)
            .bind(to: menuList.rx.items(cellIdentifier: FooiyCell.cellId, cellType: FooiyCell.self)) { index, item, cell in
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let formatPrice = numberFormatter.string(from: NSNumber(value: Int(item.price)))
                cell.bigLabel.text = item.name
                cell.smallLabel.text = formatPrice! + "원"
            }.disposed(by: disposeBag)
    }
    
}


extension SelectMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !NetworkMonitor.shared.isConnected {
            showNetworkErrorAlert()
            return
        }
        let recordViewController = RecordShopViewController()
        guard let getShopInfo = UserDefaultsManager.shopInfo else {
            print("UserDefaultsManager Bug")
            return
        }
        var shopInfo = getShopInfo
        shopInfo.shop_id = self.shopId
        shopInfo.menu_id = viewModel.menuList.value[indexPath.row].id
        shopInfo.menu_name = viewModel.menuList.value[indexPath.row].name
        UserDefaultsManager.shopInfo = shopInfo
        self.navigationController?.pushViewController(recordViewController, animated: true)
    }
}

extension SelectMenuViewController {
    
    private func initAttributes() { }
    
    private func initUI() { }
    
}
