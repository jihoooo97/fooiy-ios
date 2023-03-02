import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

final class SearchShopViewController: UIViewController {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var navigationBarLine = UIView()
    lazy var searchTextField = FooiySearchTextFieldView()
    lazy var shopListTableView = UITableView()
    lazy var stackView = UIStackView()
    lazy var noShopImage = UIImageView()
    lazy var explainView = UIView()
    lazy var explainTitle = UILabel()
    lazy var explainImage1 = UIImageView()
    lazy var explainMainLabel1 = UILabel()
    lazy var explainSubLabel1 = UILabel()
    lazy var explainImage2 = UIImageView()
    lazy var explainMainLabel2 = UILabel()
    lazy var explainSubLabel2 = UILabel()
    lazy var safeArea = UILayoutGuide()
    
    var paging = true
    
    let viewModel = SearchShopViewModel()
    let disposeBag = DisposeBag()
    
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        initUI()
        inputBind()
        outputBind()
    }
    
    private func inputBind() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        searchTextField.textField.searchButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self).map { $0.0 }
            .bind {
                let keyword = $0.searchTextField.textField.text ?? ""
                $0.viewModel.searchTextSubject.accept(keyword)
                $0.viewModel.searchShop(keyword: keyword,
                                        location: $0.location!)
                $0.shopListTableView.setContentOffset(CGPoint(x: 0, y: 16), animated: false)
                $0.searchTextField.textField.resignFirstResponder()
            }.disposed(by: disposeBag)
        
        shopListTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let item = (self?.viewModel.shopListSubject.value[indexPath.row])!
                let shopDetailViewController = ShopDetailViewController()
                shopDetailViewController.shopName = item.name
                shopDetailViewController.shopAddress = item.address
                shopDetailViewController.delegate = self
                shopDetailViewController.viewModel = self?.setShopViewModel(id: item.publicId)
                self?.searchTextField.textField.resignFirstResponder()
                self?.navigationController?.pushViewController(shopDetailViewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func outputBind() {
        viewModel.shopListSubject
            .subscribe(on: MainScheduler.instance)
            .bind(to: shopListTableView.rx.items(
                cellIdentifier: FooiyShopCell.cellId,
                cellType: FooiyShopCell.self)
            ) { (index, item, cell) in
                cell.setData(shopInfo: item)
            }.disposed(by: disposeBag)
        
        viewModel.shopListSubject
            .bind(onNext: { [weak self] shopList in
                self?.viewModel.hideExplainSubject.accept(shopList.count > 0)
                let shopTotal = self?.viewModel.shopListTotalSubject.value ?? 0
                if shopList.count < shopTotal {
                    self?.paging = true
                } else {
                    self?.paging = false
                }
            }).disposed(by: disposeBag)
        
        shopListTableView.rx.didScroll
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let shopTotal = self.viewModel.shopListTotalSubject.value
                if shopTotal <= 20 { return }
                let offsetY = self.shopListTableView.contentOffset.y
                let contentHeight = self.shopListTableView.contentSize.height
                let paginationY = self.shopListTableView.frame.size.height
                if offsetY > (contentHeight - paginationY - 1360) && self.paging {
                    self.paging = false
                    let keyword = self.viewModel.searchTextSubject.value
                    self.viewModel.patchShopList(keyword: keyword, location: self.location!)
                }
            }).disposed(by: disposeBag)
        
        searchTextField.textField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(onNext: { [weak self] in
                let state = $0.isEmpty ? FooiyColors.G200 : FooiyColors.G400
//                self?.searchTextField.textField.searchButton.isEnabled = !$0.isEmpty
                self?.searchTextField.textFieldLine.backgroundColor = state
                self?.searchTextField.textField.searchButton.tintColor = state
            }).disposed(by: disposeBag)
        
        viewModel.noShopImageSubject
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                if image != "" {
                    let url = URL(string: image)
                    self?.noShopImage.kf.setImage(with: url)
                    self?.noShopImage.isHidden = false
                } else {
                    self?.noShopImage.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        viewModel.hideExplainSubject
            .bind(to: stackView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
}


extension SearchShopViewController {
    
    private func initAttributes() {}
    
    private func initUI() {}
    
}

extension SearchShopViewController: ShopDetailProtocol {
    // delegate 메서드
    func setShopViewModel(id: String) -> ShopDetailViewModel {
        let viewModel = ShopDetailViewModel(shopID: id)
        return viewModel
    }
    
}

extension SearchShopViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField.textField && textField.text!.count > 0 {
            self.viewModel.searchTextSubject.accept(textField.text!)
            self.viewModel.searchShop(keyword: textField.text!, location: location!)
        }
        self.shopListTableView.setContentOffset(CGPoint(x: 0, y: 16), animated: false)
        textField.resignFirstResponder()
        return true
    }
    
}

extension SearchShopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
}
