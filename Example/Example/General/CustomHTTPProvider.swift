import Foundation
import RemoteConfiguration
import Alamofire

extension Alamofire.Request : RemoteConfiguration.Request { }

public final class CustomHTTPProvider: Provider {
    public func request(with url: URL, success: @escaping (Data) -> Void,
                        failure: @escaping (RemoteConfiguration.Error) -> Void) -> RemoteConfiguration.Request {
        let request = Alamofire.request(url.absoluteString).response { (response) in
            guard let data = response.data, response.error == nil else {
                return failure(RemoteConfiguration.Error.provider(message: "An error occurred"))
            }
            success(data)
        }
        request.resume()
        return request
    }
}
