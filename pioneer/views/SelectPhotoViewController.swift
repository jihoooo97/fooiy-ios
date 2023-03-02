import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation
import Kingfisher

protocol UpdatePhotoDelegate: NSObjectProtocol {
    func updatePhoto(image: UIImage, address: CLLocation?)
}

final class SelectPhotoViewController: UIViewController, UIGestureRecognizerDelegate {

    lazy var navigationBar = UIView()
    lazy var navigationTitle = UILabel()
    lazy var navigationNextButton = UIButton()
    lazy var navigationBarLine = UIView()
    lazy var backButton = FooiyButton(type: .backImageButton)
    lazy var selectPhotoButton = UIButton()
    lazy var selectedPhoto = UIImageView()
    lazy var explainIcon = UIImageView()
    lazy var explainTitle = UILabel()
    lazy var explainLabel1 = UILabel()
    lazy var explainLabel2 = UILabel()
    lazy var explainLabel3 = UILabel()
    
    var shopId = ""
    var shopName = ""
    var address = ""
    
    let viewModel = SelectPhotoViewModel()
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
                // 이미지로 인한 메모리 관리 생각
                self?.selectedPhoto.image = nil
                DataStorage<Data>.remove(forKey: .foodImage)
                UserDefaultsManager.shopInfo = nil
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        navigationNextButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                if !NetworkMonitor.shared.isConnected {
                    self?.showNetworkErrorAlert()
                    return
                }
                if self?.address != "" && self?.shopId != "" && self?.shopName != "" {
                    guard let address = self?.address,
                          let shopName = self?.shopName,
                          let shopId = self?.shopId
                    else { return }
                    let selectMenuViewController = SelectMenuViewController()
                    selectMenuViewController.shopId = shopId
                    selectMenuViewController.shopName = shopName
                    selectMenuViewController.address = address
                    self?.navigationController?.pushViewController(selectMenuViewController, animated: true)
                } else {
                    self?.viewModel.nextButtonClick()
                }
            }).disposed(by: disposeBag)
        
        selectPhotoButton.rx.tap
            .bind(onNext: { [weak self] in
                let dialogView = FooiyDialogView()
                dialogView.dialogType = FooiyDialogType.photo
                dialogView.modalPresentationStyle = .overCurrentContext
                dialogView.modalTransitionStyle = .crossDissolve
                dialogView.delegate = self
                self?.present(dialogView, animated: false)
            }).disposed(by: disposeBag)
    }
    
    private func bind() {
        selectedPhoto.rx.isEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                self?.navigationNextButton.isEnabled = !isEmpty
            }).disposed(by: disposeBag)
        
        viewModel.locationAuthRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] auth in
                if auth == true {
                    let addressEnable = self?.viewModel.addressExist() ?? false
                    let setAddressViewController = SetAddressViewController()
                    if addressEnable { // 사진에 위치 정보가 있음
                        setAddressViewController.location = (self?.viewModel.address)!
                    } else {           // 사진에 위치 정보가 없음
                        setAddressViewController.location = LocationManager.shared.currentLocation
                    }
                    self?.navigationController?.pushViewController(setAddressViewController, animated: true)
                } else if auth == false {
                    self?.viewModel.locationAuthRelay.accept(nil)
                    let popupView = FooiyPopupViewController()
                    popupView.modalPresentationStyle = .overFullScreen
                    popupView.popupType = .normal
                    self?.present(popupView, animated: false)
                } else {
                    let popupView = FooiyPopupViewController()
                    popupView.modalPresentationStyle = .overFullScreen
                    popupView.popupType = .location
                    self?.present(popupView, animated: false)
                }
            }).disposed(by: disposeBag)
    }
    
}


extension SelectPhotoViewController {
    
    private func initAttributes() {
        navigationBar = {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }()
        
        navigationTitle = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = FooiyStrings.selectPhotoNavigationTitle
            label.textColor = FooiyColors.G900
            label.font = FooiyFonts.SubTitle2
            return label
        }()
        
        navigationNextButton = {
            let button = UIButton()
            button.isEnabled = false
            button.setTitle("다음", for: .normal)
            button.setTitleColor(FooiyColors.P500, for: .normal)
            button.setTitleColor(FooiyColors.G200, for: .disabled)
            button.titleLabel?.font = FooiyFonts.Button
            return button
        }()
        
        navigationBarLine = {
            let view = UIView()
            view.backgroundColor = FooiyColors.G100
            return view
        }()
        
        selectPhotoButton = {
            let button = UIButton()
            button.setTitle("사진 등록", for: .normal)
            button.setTitleColor(FooiyColors.G600, for: .normal)
            button.setImage(FooiyIcons.addPhoto, for: .normal)
            button.titleLabel?.font = FooiyFonts.Heading3
            button.alignTextBelow()
            button.backgroundColor = FooiyColors.G100
            button.tintColor = FooiyColors.G400
            return button
        }()
        
        selectedPhoto = {
            let imageView = UIImageView()
            imageView.isHidden = true
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        explainIcon = {
            let image = UIImageView()
            image.image = FooiyIcons.info
            image.tintColor = FooiyColors.G600
            return image
        }()
        
        explainTitle = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = FooiyStrings.selectPhotoExplainTitle
            label.textColor = FooiyColors.G600
            label.font = FooiyFonts.Heading3
            return label
        }()
        
        explainLabel1 = {
            let label = UILabel()
            label.text = FooiyStrings.selectPhotoExplainLabel1
            label.textColor = FooiyColors.G600
            label.font = FooiyFonts.Body2
            return label
        }()
        
        explainLabel2 = {
            let label = UILabel()
            label.text = FooiyStrings.selectPhotoExplainLabel2
            label.textColor = FooiyColors.G600
            label.font = FooiyFonts.Body2
            return label
        }()
        
        explainLabel3 = {
            let label = UILabel()
            label.text = FooiyStrings.selectPhotoExplainLabel3
            label.textColor = FooiyColors.G600
            label.font = FooiyFonts.Body2
            return label
        }()
    }
    
    private func initUI() {
        view.backgroundColor = .white
        // super view
        [navigationBar, selectPhotoButton, selectedPhoto,
         explainIcon, explainTitle,
         explainLabel1, explainLabel2, explainLabel3]
            .forEach { view.addSubview($0) }
        
        // navigation bar
        [backButton, navigationTitle, navigationNextButton, navigationBarLine]
            .forEach { navigationBar.addSubview($0) }
        
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(FooiyConstraints.navigationBarHeight)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(FooiyConstraints.selectPhotoLeading)
            $0.centerY.equalTo(navigationBar)
            $0.width.height.equalTo(FooiyConstraints.buttonSize24)
        }
        
        navigationTitle.snp.makeConstraints {
            $0.centerX.centerY.equalTo(navigationBar)
        }
        
        navigationNextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(FooiyConstraints.selectPhotoTrailing)
            $0.centerY.equalTo(backButton)
        }
        
        navigationBarLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(navigationBar)
            $0.height.equalTo(1)
        }
        
        selectPhotoButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.height.equalTo(selectPhotoButton.snp.width)
        }
        
        selectedPhoto.snp.makeConstraints {
            $0.edges.equalTo(selectPhotoButton)
        }
        
        explainIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(FooiyConstraints.selectPhotoLeading)
            $0.top.equalTo(selectPhotoButton.snp.bottom).offset(FooiyConstraints.selectPhotoExplainIconTop)
            $0.width.height.equalTo(FooiyConstraints.iconSize24)
        }
        
        explainTitle.snp.makeConstraints {
            $0.leading.equalTo(explainIcon.snp.trailing).offset(FooiyConstraints.selectPhotoExplainTitleLeading)
            $0.centerY.equalTo(explainIcon)
        }
        
        explainLabel1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(FooiyConstraints.selectPhotoExplainLabel1Leading)
            $0.top.equalTo(explainTitle.snp.bottom).offset(FooiyConstraints.selectPhotoExplainLabel1Leading)
        }
        
        explainLabel2.snp.makeConstraints {
            $0.leading.equalTo(explainLabel1.snp.leading)
            $0.top.equalTo(explainLabel1.snp.bottom).offset(FooiyConstraints.selectPhotoExplainLabel2Top)
        }
        
        explainLabel3.snp.makeConstraints {
            $0.leading.equalTo(explainLabel1.snp.leading)
            $0.top.equalTo(explainLabel2.snp.bottom).offset(FooiyConstraints.selectPhotoExplainLabel2Top)
        }
    }
    
}

extension SelectPhotoViewController: UpdatePhotoDelegate {

    func updatePhoto(image: UIImage, address: CLLocation?) {
        // image update
        self.selectedPhoto.isHidden = false
        self.dismiss(animated: true)
        self.viewModel.address = address
        self.viewModel.setImage(image: image)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] photo in
                self?.selectedPhoto.image = photo.resize(newWidth: (self?.selectedPhoto.frame.width)!)

                guard let pngData = photo.pngData() else { return }
                let shopInfo = RecordRequest(shop_id: "",
                                             menu_id: -1,
                                             menu_name: "",
                                             comment: "",
                                             taste_evaluation: -1,
                                             image_1: pngData)
                UserDefaultsManager.shopInfo = shopInfo
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }

}
