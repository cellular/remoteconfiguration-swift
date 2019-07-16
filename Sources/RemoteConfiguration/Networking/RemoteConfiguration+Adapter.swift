import Networking

// MARK: - Public Adapter Bridge

/// The adapter class to be used by the `RemoteConfiguration`, or the managing class, in
/// order to "bridge" the `Networking.Provider` with the `RemoteConfiguration.Provider`.
///
/// - Parameter provider: The `Networking.Provider` to be "bridged" to the `RemoteConfiguration`.
/// - Returns: The "bridged" `Networking.Provider` provider, as `RemoteConfiguration` conform `Provider`.
public func adapter(for provider: Networking.Provider) -> RemoteConfiguration.Provider {
    return RemoteConfigurationAdapterProvider(provider: provider)
}

// MARK: - Private Adapter Implementation

/// Defines a simple wrapper struct for the networking provider, in order to conform to the `RemoteConfiguration`.
private struct RemoteConfigurationAdapterProvider: RemoteConfiguration.Provider {

    // MARK: Remote Configuration Request

    /// Defines a simple wrapper struct for the networking request, in order to conform to the `RemoteConfiguration`.
    private struct Request: RemoteConfiguration.Request {

        /// The networking request, wrapped within `self`.
        private let request: Networking.Request

        /// Initializes a new instance of `Self`, wrapping the given networking request.
        fileprivate init(request: Networking.Request) {
            self.request = request
        }

        /// Cancels the request.
        fileprivate func cancel() {
            request.cancel()
        }
    }

    /// The networking provider, wrapped within `self`.
    private let provider: Networking.Provider

    /// Initializes a new instance of `Self`, wrapping the given networking provider.
    fileprivate init(provider: Networking.Provider) {
        self.provider = provider
    }

    /// Starts a request using the specified URL to load the JSON dictionary used to create a Configuration instance.
    ///
    /// - Parameters:
    ///   - url: The URL from which the JSON should be requested
    ///   - success: Request success callback; the data parameter should represent the requested configuration JSON Data.
    ///   - failure: Request failure callback; the error parameter shloud represent the cause of the failure.
    fileprivate func request(
        with url: URL, success: @escaping (Data) -> Void,
        failure: @escaping (RemoteConfiguration.Error) -> Void) -> RemoteConfiguration.Request {

        let request = provider.request(.get, url: url.absoluteString, parameters: nil, encoding: .json, header: nil)
        request.onCompleted({ result in
            switch result {
            case let .success(response):
                guard let data = response.data else {
                    let error = "Remote Configuration response does not contain body data."
                    return failure(RemoteConfiguration.Error.provider(message: error))
                }
                success(data)
            case let .failure(error):
                failure(RemoteConfiguration.Error.provider(message: error.localizedDescription))
            }
        })

        return Request(request: request)
    }
}
