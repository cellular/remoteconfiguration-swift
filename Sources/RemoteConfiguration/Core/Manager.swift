import CELLULAR
import LocalStorage
import Foundation

/// Manager class used by an Application to request and process a remote configuration.
///
/// Manager provides an API to request remote configurations and provide information on available updates.
/// Requests will use a given Provider to load data. An Application can provide its own Provider implementation to keep control
/// over the details of configuration data requests.
/// Manager uses a Deserializer to process and convert configuration data into a Configuration. Applications can provide their own
/// implementation to keep control over the details of data deserialization. See property 'deserializer'.
/// Manager will use a local cache per default if configuration requests fail. To disable this feature, set 'ignoreCache' to true.
///
/// For the time being a RemoteConfiguration can only be defined as a JSON dictionary.
///
/// A valid RemoteConfiguration needs to define the following data:
/// *    `urlConfig` (required) key with a Dictionary as value (required)
/// *    `appUpdate` (required) key with a Dictionary containg the following data:
/// **   `availableVersion` (required)
/// **   `url` (required)
/// **   `type` (required)
///
/// Additionally, in case the update is defined as `recommended` or `mandatory`, the following information is required:
/// **   `localizedStrings` key containig the following information on update options available to the user:
/// ***  `languageCode` (optional)
/// ***  `regionCode` (optional)
/// ***  `title` (required)
/// ***  `text` (required)
/// ***  `options` (required) with each option defining the following keys:
/// **** `title` (required)
/// **** `isUpdateAction` (required when set to true)
///
public final class Manager {

    // MARK: - Public Properties

    /// The request, initiated by the provider on `requestConfiguration:`, managed by `self` and responsible for receiving the config data.
    private(set) public var request: Request?

    /// The URL from which the configuration data is to be loaded.
    public let url: URL

    /// If set to `true`, the Manager's persistent local cache will be ignored if configuration data could not be requested.
    /// Default value is `false`.
    public var ignoreCache: Bool = false

    /// The optional Bundle from which to load the optional bundled configuration file.
    /// Defaults to `Bundle.main`, if not explicitly set to `nil` or another `Bundle`.
    /// See also configurationBundleFilename.
    public var configurationBundle: Bundle? = .main

    /// The name of the bundled configuration data file. If set, the ConfigurationManager will try to use this file to create a
    /// Configuration if requesting the configuration's data failed and local persitent cache is disabled or not available.
    /// The file name must either have the suffix ".json" or no suffix at all.
    /// Default value is nil.
    /// See also configurationBundle
    public var configurationBundleFilename: String?

    // MARK: - Private Properties

    /// The Manager's cache holding the current configuration context, e.g the last loaded configuration and last discarded version.
    internal let cache: ConfigurationCache

    // MARK: - Initialization

    /// Creates a new instance of a ConfigurationManager using the specified URL as configuration data source and currentVersion as
    /// refernce version to check against for updates.
    /// - Paramter url: The URL to be used as configuration data source
    /// - Parameter currentVersion: The current version of the Application using the Manager instance
    public init(url: URL) {
        self.url = url
        cache = ConfigurationCache()
    }

    // MARK: - Public functions

    /// Clears the local Configuration cache.
    public func clearCache() {
        cache.clear()
    }

    /// Tries to load the last loaded remote configuration data from the Manager's cache using the specified Deserializer.
    /// - Parameter deserializer: The Deserializer implementation to be used to create the resulting configuration model
    /// - Returns: The last loaded configuration model or nil if the cache is empty or the model could not be deserialized
    public func loadFromCache<T: Deserializer>(using deserializer: T) -> T.Model? {
        guard let data = cache.lastLoadedConfiguration else { return nil }
        return try? deserializer.deserialize(from: data)
    }

    /// Requests remote configuration data from the associated URL using the associated Provider and Deserializer.
    /// Executes the completion closure on either success or failure, with appropriate values.
    /// - Parameter provider: The Provider implementation to be used to request the configuration data
    /// - Parameter deserializer: The Deserializer implementation to be used to create the resulting configuration model
    /// - Parameter completion: The completion closure to be executed when the requests finishes
    public func request<T: Deserializer>(using provider: Provider, with deserializer: T,
                                         completion: @escaping (Result<State<T.Model>, Swift.Error>) -> Void) {

        // Cancel the active request & (re-)start a new config data request
        request?.cancel()
        request = provider.request(with: url,
            success: { [weak self] data in
                // remote loading successful; deserialize config
                self?.deserialize(using: deserializer, from: data, isCacheHit: false, completion: completion)
            },
            failure: { [weak self] error in

                // remote loading failed; try fallback mechanisms
                var data: Data?

                // try to load config from cache if enabled
                if self?.ignoreCache == false {
                    data = self?.cache.lastLoadedConfiguration
                }

                // if no cached data is available, try to load config from bundle if set
                if data == nil, let file = self?.configurationBundleFilename {
                    data = self?.loadBundledConfiguration(file: file)
                }

                // deserialize config or return Failure result
                if let configData = data {
                    self?.deserialize(using: deserializer, from: configData, isCacheHit: true, completion: completion)
                } else {
                    var errorMessage: String
                    switch error {
                    case let .provider(message):
                        errorMessage = message + "; "
                    default:
                        errorMessage = "Error requesting Configuration: " + error.localizedDescription + "; "
                    }
                    errorMessage += "Configuration cache and bundled Configuration disabled and/or unavailable."
                    completion(.failure(Error.provider(message: errorMessage)))
                }
            }
        )
    }

    /// Should be called by client Apps when a user decides to discard a recommended update, so that an alert will no longer
    /// be shown for the given version.
    ///
    /// - Parameter configuration: the configuration for which the update has been discarded by the user
    public func discardRecommendedUpdate(for update: UpdateContext) {
        cache.lastDiscardedVersion = update.availableVersion
    }

    // MARK: - Private functions

    private func deserialize<T: Deserializer>(using deserializer: T, from data: Data, isCacheHit: Bool,
                                              completion: @escaping (Result<State<T.Model>, Swift.Error>) -> Void) {

        // deserialize Configuration and set its origin property
        let configuration: T.Model
        do {
            configuration = try deserializer.deserialize(from: data)
        } catch let error {
            return completion(.failure(error))
        }

        // if config was valid and loaded by provider, update local cache
        if !isCacheHit {
            cache.lastLoadedConfiguration = data
        }

        // determine effective update type by checking discarded update context
        let updateType: UpdateType
        if isDiscardedUpdate(configuration) {
            updateType = .discarded
        } else {
            updateType = configuration.appUpdate.updateType
            cache.lastDiscardedVersion = nil // updateType/frequency/version do not qualify for discarded update -> reset
        }

        // create config context and return Success result
        completion(.success(.init(configuration: configuration, contextualUpdateType: updateType)))
    }

    // MARK: - Private helper functions

    private func isDiscardedUpdate(_ configuration: Configuration) -> Bool {
        // check if the user has already discarded this recommended update and the alert frequency is set to 'once'
        return configuration.appUpdate.updateType == .recommended
            && configuration.appUpdate.alertFrequency == .once
            && configuration.appUpdate.availableVersion == cache.lastDiscardedVersion
    }

    private func loadBundledConfiguration(file: String) -> Data? {
        let fileName = configurationFileName(name: file)
        guard let path = configurationBundle?.path(forResource: fileName, ofType: "json") else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: path), options: [])
    }

    private func configurationFileName(name: String) -> String {
        let fileName = name as NSString
        let fileExtension = ".json"
        return fileName.hasSuffix(fileExtension) ? fileName.deletingPathExtension : fileName as String
    }
}
