import UIKit
import RxSwift

protocol FooiyDeleteRecordDelegate: AnyObject {
    func deleteRecordPossible(feedType: String, publicID: String) -> Bool
    func getRecordID(id: String) -> String
}

class FooiyBottomSheetViewController: UIViewController {
    
    let bottomHeight: CGFloat = 188
    var deleteRecordButton = UIButton()
    var fixButton = UIButton()
    let disposeBag = DisposeBag()
    var deletgate: FooiyDeleteRecordDelegate?
    var recordID: String?
    var evaluationImageUrl: String = ""
    var commentText: String = ""
    var loadingView = LoadingView(type: .main)
    
    var safeArea = UILayoutGuide()
    
    var deleteRecordPossible: Bool? {
        didSet {
            if deleteRecordPossible != true {}
            else {}
        }
    }
    
    private var bottomSheetViewTopConstraint: NSLayoutConstraint!
    
    private let dimmedBackView = UIView()
    
    private let bottomSheetView = UIView()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAttributes()
        setupGestureRecognizer()
        
        fixButton.rx.tap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
            }).disposed(by: disposeBag)
        
        deleteRecordButton.rx.tap
            .bind { [weak self] in
        }.disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }

    func deleteRecord(recordID: String) {
        
        guard let possible = deleteRecordPossible else { return }
        
        if possible {
            FeedService.shared.deleteRecord(recordID: recordID)
                .subscribe(onSuccess: { [weak self] response in

                }, onFailure: { [weak self] err in

                }).disposed(by: disposeBag)
        }

    }
    
    private func initAttributes() {
        // Set UI Attributes
    }
    
    private func initUI() {
        // Set Constraints
    }
    
    // GestureRecognizer 세팅 작업
    private func setupGestureRecognizer() {}
    
    // 바텀 시트 표출 애니메이션
    private func showBottomSheet() {}
    
    // 바텀 시트 사라지는 애니메이션
    private func hideBottomSheetAndGoBack() {}
    
    // UITapGestureRecognizer 연결 함수 부분
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    // UISwipeGestureRecognizer 연결 함수 부분
    @objc func panGesture(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .ended {
            switch recognizer.direction {
            case .down:
                hideBottomSheetAndGoBack()
            default:
                break
            }
        }
    }
    
}
