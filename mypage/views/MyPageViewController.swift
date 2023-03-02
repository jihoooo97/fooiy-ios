import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxDataSources

class MyPageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var viewModel: MyPageViewModel?
    var disposeBag = DisposeBag()
    var safetyArea = UIView()
    var tabbarSafetyArea = UIView()
    var stickyHeaderView = UIView()
    var topView = UIView()
    var fooiyLogo = UIImageView(image: FooiyIcons.foiyLogoG400)
    var alarmButton = UIButton()
    var fooiytiButton = UIButton()
    var profileImageView = UIImageView()
    var profileGradationSuperView = UIImageView()
    var pioneerLabel = UILabel()
    var pioneerValueLabel = UILabel()
    var recordLabel = UILabel()
    var recordValueLabel = UILabel()
    var userNickNameLabel = UILabel()
    var userIntroductionLabel = UILabel()
    var settingButton = UIButton()
    var settingLabel = UILabel()
    var allButton = UIButton()
    var pioneerButton = UIButton()
    var recordButton = UIButton()
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: FooiyCollectionViewFlowLayout())
    lazy var buttonArray = [allButton, pioneerButton, recordButton]
    var refreshControl = UIRefreshControl()
    var storageButton = UIButton()
    
    let tabbarList = ["피드", "지도"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttribute()
        initUI()
        setButtonClickEvent()
        bind()
    }
    
    private func setButtonClickEvent() {
        fooiytiButton.rx.tap
            .bind { [weak self] _ in
                let mypageFooiytiViewController = MyPageFooiytiViewController()
                self?.navigationController?.pushViewController(mypageFooiytiViewController, animated: true)
            }.disposed(by: disposeBag)
        
        alarmButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                let mypageAlarmViewController = PushNotificationViewController()
                self.navigationController?.pushViewController(mypageAlarmViewController, animated: true)
            }.disposed(by: disposeBag)

        settingButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
            guard let self = self else { return }
            let mypageSettingViewController = MyPageSettingViewController()
            self.navigationController?.pushViewController(mypageSettingViewController, animated: true)
        }.disposed(by: disposeBag)
    }
    
    
    private func bind() {
        allButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {}
            .disposed(by: disposeBag)
        
        pioneerButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {}
            .disposed(by: disposeBag)
        
        recordButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind {}
            .disposed(by: disposeBag)
        
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.newPushRelay
            .bind {}
            .disposed(by: disposeBag)
        
        viewModel.otherAccountInfoRelay
            .observe(on: MainScheduler.instance)
            .bind {}
            .disposed(by: disposeBag)
        
        viewModel.currentMypageType
            .observe(on: MainScheduler.instance)
            .bind {}
            .disposed(by: disposeBag)
    }
    
    @objc func refresh() {
        refreshControl.endRefreshing()
    }
}


extension MyPageViewController: myPageFeedProtocol {
    func setMyPageFeedViewModel(id: String, type: MyPageFeedType, feedID: String, feedType: String) -> MyPageFeedViewModel {
        let mypageFeedViewModel = MyPageFeedViewModel(accoutID: id, mypageFeedType: type, feedID: feedID, feedType: feedType)
        return mypageFeedViewModel
    }
}

extension MyPageViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
}

extension MyPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
}

extension MyPageViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { }
    
}

extension MyPageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { }
    
}


extension MyPageViewController {
    
    @objc func goToFooiyti() {
        let fooiytiInformationInputViewController = FooiytiInformationInputViewController()
        fooiytiInformationInputViewController.didUserFooiytiTest = false
        GatewayViewController.share?.fooiyTabbar.isHidden = true
        self.navigationController?.pushViewController(fooiytiInformationInputViewController, animated: true)
    }
    
    private func deinitNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initAttribute() {
        // Set UI Attributes
    }
    
    private func initUI() {
        // Set Constraint
    }
}
