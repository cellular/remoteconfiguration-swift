import Foundation
import CELLULAR
import LocalStorage

class ConfigurationCache {

    /// Enumeration defining the different storage identifiers.
    ///
    /// - configurationContext: the storage identifier for the current configuration context
    enum StorageIdentifier: String {
        case configurationContext = "de.cellular.remoteconfiguration.storage.configurationcontext"
    }

    // MARK: - Public properties

    /// The last recommended update version that defined an alert frequency of 'once' and which the user decided to discard.
    var lastDiscardedVersion: String? {
        get {
            return loadContext()?.lastDiscardedVersion
        }
        set {
            var context = loadContext() ?? ConfigurationContext()
            context.lastDiscardedVersion = newValue
            saveContext(context)
        }
    }

    /// The last successfully loaded configuration.
    var lastLoadedConfiguration: Data? {
        get {
            return UserDefaults.standard.data(forKey: configurationCacheKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: configurationCacheKey)
        }
    }

    // MARK: - Private properties

    private let manager: LocalStorage.Manager
    private let configurationCacheKey = "de.cellular.remoteconfiguration.cache"

    // MARK: - Initializer

    init() {
        let contextStorage = UserDefaultsStorage(userDefaults: .standard, path: StorageIdentifier.configurationContext.rawValue)
        let queue = DispatchQueue(label: "de.cellular.remoteconfigurarion.cache", attributes: .concurrent)
        let lock = DispatchLock(queue: queue)
        let storages: [String: Storage] = [StorageIdentifier.configurationContext.rawValue: contextStorage]
        manager = .init(storages: storages, lock: lock, asyncQueue: queue)
    }

    // MARK: - Public functions

    func clear() {
        lastLoadedConfiguration = nil
        lastDiscardedVersion = nil
    }

    // MARK: - Private functions

    private func loadContext() -> ConfigurationContext? {
        let decoder = FoundationDecoder<ConfigurationContext>(decoder: JSONDecoder())
        let result = manager.first(from: StorageIdentifier.configurationContext.rawValue, using: decoder)
        switch result {
        case .success(let context): return context
        default: return nil
        }
    }

    private func saveContext(_ context: ConfigurationContext) {
        let encoder = FoundationEncoder<ConfigurationContext>(encoder: JSONEncoder())
        manager.replaceAll(in: StorageIdentifier.configurationContext.rawValue, with: [context], using: encoder)
    }
}
