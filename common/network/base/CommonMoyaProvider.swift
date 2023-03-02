import Foundation
import Moya

class CommonMoyaProvider<T: TargetType>: MoyaProvider<T> {
    init() {
        let networkLoggerPlugin = BaseNetworkPlugin.shared.networkLoggerPlugin
        let networkActivityPlugin = BaseNetworkPlugin.shared.networkActivityPlugin
        let configuration = BaseNetworkPlugin.shared.configuration
        let session = Session(configuration: configuration)
        
        super.init(session: session, plugins: [networkLoggerPlugin, networkActivityPlugin])
    }
}
