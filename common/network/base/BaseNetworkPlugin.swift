import Foundation
import Moya

class BaseNetworkPlugin {
    static let shared = BaseNetworkPlugin()
    
    let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(formatter: .init(entry: { (identifier, message, target) -> String in
        if identifier != "Response" {
            return "[\(identifier)] \(message)"
        }
        return "Response"
    }, requestData: { data in
        return (data.prettyPrintedJSONString as String?) ?? ""
        
    }, responseData: { data in
        let jsonDecoder = JSONDecoder()
        if let parsedData = try? jsonDecoder.decode(BaseResponse.self, from: data) {
            if let error = parsedData.error {
                // 중복 로그인 경우 앱 강제 종료
                if error.code == 4998 {
                    if let topViewController =  UIApplication.myKeyWindow?.visibleViewController {
                        if !(topViewController is UIAlertController) {
                            topViewController.showDuplicatedLoginAlert()
                        }
                    }
                }
            }
        }
        
        return (data.prettyPrintedJSONString as String?) ?? ""
        
    }), output: { target, items in
        // 로그
        print("------------------------------------------------------------")
        items.forEach { if $0 != "Response" { print($0) } }
        print("------------------------------------------------------------")
        
    }, logOptions: [.verbose]))
    
    
    let networkActivityPlugin = NetworkActivityPlugin { change, target in
        switch change {
        case .began:
            break
        case .ended:
            break
        }
    }
    
    let configuration = URLSessionConfiguration.default

    private init() {
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.headers = .default
        configuration.requestCachePolicy = .useProtocolCachePolicy
    }
}
