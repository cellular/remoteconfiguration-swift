import Foundation

/// Responsible for sending a request and receiving the response and associated data from the server.
public protocol Request {

    /// Cancels the request.
    func cancel()
}

/// Protocol defining the required functions for a Provider implementation used by the ConfigurationManager.
/// A Provider is responsible for loading the data used by the ConfigurationManager to create a Configuration instance.
public protocol Provider {

    /// Starts a request using the specified URL to load the JSON dictionary used to create a Configuration instance.
    /// - Parameter url: the URL from which the JSON should be requested
    /// - Parameter success: request success callback; the data parameter should represent the requested configuration JSON Data
    /// - Parameter failure: request failure callback; the error parameter shloud represent the cause of the failure
    func request(with url: URL, success: @escaping @Sendable (Data) -> Void, failure: @escaping @Sendable (Error) -> Void) -> Request
}
