import XCTest
@testable import RemoteConfiguration

class ConfigurationCacheTests: XCTestCase {

    var cache: ConfigurationCache!

    override func setUp() {
        super.setUp()
        cache = ConfigurationCache()
    }

    override func tearDown() {
        super.tearDown()
        cache.clear()
    }

    func testLastLoadedRemoteConfig() {

        let config = ["key" : "value"].data()
        cache.lastLoadedConfiguration = config

        guard let loadedConfig = cache.lastLoadedConfiguration?.json() else {
            XCTFail("Last loaded config is nil")
            return
        }

        assert(loadedConfig["key"] as? String == "value", "Unexpected value for config key")
    }

    func testClearCache() {

        let configuration: [String : Any] = [
            "key" : "value"
        ]

        cache.lastLoadedConfiguration = configuration.data()
        XCTAssertNotNil(cache.lastLoadedConfiguration, "ConfigurationCache is empty")
        cache.clear()
        XCTAssertNil(cache.lastLoadedConfiguration, "ConfigurationCache not empty")
    }
}
