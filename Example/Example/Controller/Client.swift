import UIKit
import RemoteConfiguration

public class Client: NSObject {

    private let manager = Manager(url:  URL(string: "http://thisisatestdomain.de")!, currentVersion: AppDelegate.appVersion)

    public func loadDefaultConfiguration(completion: @escaping (_ error: NSError?, _ data: String?) -> Void) {

        manager.request(using: HTTPProvider(), with: JSONDeserializer(), completion: { (result) in
            switch result {
            case .success(let model):
                guard var resultString = String.fromJSONObject(object: model.urlConfiguration as AnyObject)
                    else { return completion(NSError(), nil) }
                resultString.append("\n\(self.source(origin: model.origin))")
                return completion(nil, resultString)
            default:
                return completion(NSError(), nil)
            }
        })
    }

    public func loadCustomConfiguration(completion: @escaping (_ error: NSError?, _ data: String?) -> Void) {

        manager.request(using: CustomHTTPProvider(), with: CustomJSONDeserializer(), completion: { (result) in
            switch result {
            case .success(let model):
                guard var resultString = String.fromJSONObject(object: model.configFile.urlConfig as AnyObject)
                    else { return completion(NSError(), nil) }
                resultString.append("\n\(self.source(origin: model.origin))")
                return completion(nil, resultString)
            default:
                return completion(NSError(), nil)
            }
        })
    }

    public func clearCache() {
        manager.clearCache()
    }

    private func source(origin: Origin) -> String {
        switch origin {
        case .provider:
            return "Provider"
        case .cache:
            return "Cache"
        case .bundle:
            return "Bundle"
        }
    }
}
