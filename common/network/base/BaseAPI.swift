import Foundation

enum FooiyNetworkErrorType: Error {
    case clientError
    case serverError
    case unknownError
}


struct FooiyNetworkErrorEntity: Codable {
    let success: Bool
    let payload: FooiyError
}


struct FooiyError: Codable {
    let code: Int
    let message: String
}


class BaseAPI {
    
    static let shared = BaseAPI()
    
    static let baseURL: String = "url"
    static let baseV2URL: String = "url"
    
    static let imagePath: String = "url"
    static let feedPath: String = "url"
    
    static func judgeStatus(statusCode: Int) -> Result<Data?, FooiyNetworkErrorType> {
        switch statusCode {
        case 200..<400:
            return .success(nil)
        case 400..<500:
            return .failure(.clientError)
        case 500...:
            return .failure(.serverError)
        default:
            return .failure(.unknownError)
        }
    }
    
    private init() { }
    
}
