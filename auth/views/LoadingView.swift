import UIKit
import Lottie

enum LoadingType {
    case main
    case gray
}

final class LoadingView: UIView {

    var animationName: String = ""
    
    lazy var backgroundView = UIView()
    lazy var roundView = UIView()
    lazy var animationView = AnimationView()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    convenience init(type: LoadingType) {
        self.init()
        
        switch type {
        case .main:
            self.animationName = "loading_main"
        case .gray:
            self.animationName = "loading_gray"
        }
        
        initAttributes()
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initAttributes() {
        self.backgroundColor = .clear

        backgroundView = {
            let view = UIView()
            view.backgroundColor = .black
            view.alpha = 0.4
            return view
        }()
        
        roundView = {
            let view = UIView()
            if animationName == "loading_main" {
                view.backgroundColor = .white
            } else {
                view.backgroundColor = FooiyColors.G700
            }
            view.layer.cornerRadius = 40
            return view
        }()
        
        animationView = {
            let view = AnimationView()
            view.animation = Animation.named(animationName)
            view.loopMode = .loop
            view.contentMode = .scaleAspectFit
            view.play()
            return view
        }()
    }
    
    private func initUI() {
        [backgroundView, roundView, animationView]
            .forEach { self.addSubview($0) }
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        roundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        animationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-8)
            $0.width.height.equalTo(158)
        }
    }
    
}
