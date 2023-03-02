import RxSwift
import RxCocoa

final class PioneerShopViewModel {

    // MARK: Inputs
    let nameCountRelay = BehaviorRelay<Int>(value: -1)
    let menuCountRelay = BehaviorRelay<Int>(value: -1)
    let priceCountRelay = BehaviorRelay<Int>(value: -1)
    let commentCountRelay = BehaviorRelay<Int>(value: -1)
    
    // MARK: Outputs
    let bannerListSubject = BehaviorRelay<[String]>(value: [])
    let emogiListSubject = BehaviorRelay<[RegisterTasteModel]>(value: [])
    let evaluationExplainSubject = BehaviorRelay<String>(value: "")
    let resizeEmogiSubject = BehaviorRelay<[UIImage]>(value: [])
    
    let evaluationScore = BehaviorRelay<Int>(value: 50)
    let canPioneer = BehaviorRelay<Bool>(value: false)
    let isSuccess = PublishRelay<Bool>()
    let isLoading = BehaviorRelay<Bool>(value: true)
    let networkError = BehaviorRelay<Bool>(value: false)
    
    let disposeBag = DisposeBag()
    
    init(type: String) {
        setUI(type: type)
    }
    
}


extension PioneerShopViewModel {
    
    // 개척일 때 state
    func enablePioneer(_ nameCount: Int, _ menuCount: Int, _ priceCount: Int, _ comment: String) {
        if nameCount > 0 && menuCount > 0 && priceCount > 0 && comment.count >= 10 && comment != "10자 이상 적어주세요" {
            canPioneer.accept(true)
        } else {
            canPioneer.accept(false)
        }
    }
    
    // 기록일 때 state
    func enableRecord(_ comment: String) {
        if comment.count >= 10 && comment != "10자 이상 적어주세요" {
            canPioneer.accept(true)
        } else {
            canPioneer.accept(false)
        }
    }
    
    func tryPioneer(request: PioneerRequest) {
        isLoading.accept(false)
        FeedService.shared.tryPioneer(request: request)
            .subscribe(onSuccess: { [weak self] response in

            }, onFailure: { [weak self] error in

            }, onDisposed: { [weak self] in

            }).disposed(by: disposeBag)
    }
    
    func tryRecord(request: RecordRequest) {
        isLoading.accept(false)
        FeedService.shared.tryRecord(request: request)
            .subscribe(onSuccess: { [weak self] response in

            }, onFailure: { [weak self] error in

            }, onDisposed: { [weak self] in

            }).disposed(by: disposeBag)
    }
    
    private func setUI(type: String) {
        UIService.shared.setRegisterUI(type: type)
            .asObservable()
            .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(onNext: { [weak self] response in

            }, onError: { [weak self] error in

            }).disposed(by: disposeBag)
    }
    
}
