import UIKit
import SnapKit
import RxSwift
import RxCocoa


// MARK: - State
public enum BottomSheetState {
    case part
    case full
}

class BottomSheetView: UIView {
    
    var barView = UIView()
    var titleLabel = UILabel()
    var shopListTableView = UITableView()
    var zoomLevelOutLabel = UILabel()
    
    var partScreenY: CGFloat = 0
    var fullScreenY: CGFloat = 0
    var translationSumY: CGFloat = 0.0
    var state: BottomSheetState = .part
    var panGestureInStroke = false
    
    let disposeBag = DisposeBag()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan))
        return pan
    }()
    
    var bottomSheetColor: UIColor? {
        didSet { self.backgroundColor = self.bottomSheetColor }
    }
    var barViewColor: UIColor? {
        didSet { self.barView.backgroundColor = self.barViewColor }
    }
    
    ///  테이블뷰 배경
    ///  nil이 들어오면 사라집니다.
    public var backgroundHidden: Bool {
        get { return (shopListTableView.backgroundView?.isHidden)! }
        
        set {
            shopListTableView.backgroundView?.isHidden = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initAttributes()
        initUI()
    }
    
    private func initAttributes() { }
    
    private func initUI() { }
    
    // MARK: - Drag
    private func showMapListWithAnimation() {
        UIView.animate(
            withDuration: 0.3,
            animations: {[weak self] in
                let frame = self?.frame
                self?.frame = CGRect(x: 0, y: self?.partScreenY ?? 0, width: frame!.width, height: frame!.height)
            }
        )
    }
    
    @objc func handlePan(recog: UIPanGestureRecognizer) {
        // stroke 부분을 건드릴 경우에 대해서
        let loc = recog.location(in: self).y
        if recog.state == .began && -10 <= loc && loc <= shopListTableView.frame.minY {
            panGestureInStroke = true
        }

        let direction = recog.velocity(in: self).y
        let listY = shopListTableView.contentOffset.y

        if !panGestureInStroke {
            // 리스트의 가장 위일때 panGesture 실행하지 않음
            if -20 > listY || listY > 0 {
                recog.setTranslation(CGPoint.zero, in: self)
                return
            }
            // fullScreen이고 내리는 행동을 할 경우 panGesture 실행하지 않음
            if self.frame.minY == fullScreenY && direction < 0 {
                recog.setTranslation(CGPoint.zero, in: self)
                shopListTableView.isScrollEnabled = true
                return
            }
        }

        shopListTableView.isScrollEnabled = false

        let translationY = recog.translation(in: self).y
        self.translationSumY += translationY

        let minY = self.frame.minY
        let boundaryY = UIScreen.main.bounds.height / 9
        var y = minY + translationY

        switch recog.state {
        case .ended, .cancelled:
            if recog.state == .ended { panGestureInStroke = false }

            if y > partScreenY - boundaryY {
                applyPartScreen()
            } else if y < fullScreenY + boundaryY {
                applyFullScreen()
            } else if self.translationSumY >= 0 {
                applyPartScreen()
            } else {
                applyFullScreen()
            }

            self.translationSumY = 0.0
        case .changed, .began:
            titleLabel.isHidden = false

            y = max(y, fullScreenY)
            y = min(y, partScreenY)

            self.frame = CGRect(
                x: 0,
                y: y,
                width: self.frame.width,
                height: self.frame.height
            )
            recog.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    func applyPartScreen() {
        let frame = self.frame
        state = .part

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.frame = CGRect(x: 0, y: self?.partScreenY ?? 0, width: frame.width, height: frame.height)
                
            }
        )
    }
    
    func applyFullScreen() {
//        print("full -> \(fullScreenY)")
        let frame = self.frame
        state = .full
        shopListTableView.isScrollEnabled = true

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.frame = CGRect(x: 0, y: self?.fullScreenY ?? 0, width: frame.width, height: frame.height)
            }
        )
    }
    
}

extension BottomSheetView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}
