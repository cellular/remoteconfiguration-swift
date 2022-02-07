import XCTest
@testable import RemoteConfiguration

class ManagerTests: XCTestCase {

    private var manager: Manager!

    // MARK: - TestFixture

    override func setUp() {
        super.setUp()
        manager = Manager(url: URL(string: "http://nohost.com")!)
    }

    override func tearDown() {
        super.tearDown()
        manager.clearCache()
        manager = nil
    }

    // MARK: - Test functions

    func testIgnoreUpdateSameVersion() {

        let response = [
            "urlConfig": ["key": "value"],
            "appUpdate": [
                "availableVersion": "1.3",
                "url": "http://nohost.com",
                "type": "ignore"
            ]
        ].data()

        // failure and updateAvailable callbacks must not be executed; Test should fail in that case
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "Configuration cache not empty")

        let provider = TestProvider(response: response)
        manager.request(using: provider, with: DefaultDeserializer(), completion: { [weak self] result in
            switch result {
            case let .success(state):
                XCTAssert(state.configuration.appUpdate.updateType == .ignore, "Unexpected Configuration UpdateType")
                XCTAssert(state.contextualUpdateType == .ignore, "Unexpected contextual UpdateType")
                XCTAssertNotNil(self?.manager.cache.lastLoadedConfiguration)
            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }

    func testRecommendedUpdateNewVersion() {

        let response = [
            "urlConfig": [
                "key": "value"
            ],
            "appUpdate": [
                "availableVersion": "1.2.1",
                "url": "http://nohost.com",
                "type": "recommended",
                "localizedStrings": [
                    [
                        "title": "title",
                        "text": "message",
                        "options": [
                            [
                                "title": "update",
                                "isUpdateAction": true
                            ]
                        ]
                    ]
                ]
            ]
        ].data()

        // failure callback must not be executed; Test should fail in that case
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "Configuration cache not empty")

        let provider = TestProvider(response: response)
        manager.request(using: provider, with: DefaultDeserializer(), completion: { [weak self] result in

            switch result {
            case let .success(state):
                // validate completion is called with expected configuration
                XCTAssertTrue(state.configuration.appUpdate.updateType == .recommended, "Unexpetced Configuration UpdateType")
                XCTAssertTrue(state.contextualUpdateType == .recommended, "Unexpetced contextual UpdateType")
                XCTAssertNotNil(self?.manager.cache.lastLoadedConfiguration)
            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }

    func testMandatoryUpdateNewVersion() {

        let response = [
            "urlConfig": [
                "key": "value"
            ],
            "appUpdate": [
                "availableVersion": "1.2.1",
                "url": "http://nohost.com",
                "type": "mandatory",
                "localizedStrings": [
                    [
                        "title": "title",
                        "text": "message",
                        "options": [
                            [
                                "title": "update",
                                "isUpdateAction": true
                            ]
                        ]
                    ]
                ]
            ]
        ].data()

        // failure callback must not be executed; Test should fail in that case
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "Configuration cache not empty")

        let provider = TestProvider(response: response)
        manager.request(using: provider, with: DefaultDeserializer(), completion: { result in

            switch result {
            case let .success(state):
                // validate completion is called with expected configuration
                XCTAssertTrue(state.configuration.appUpdate.updateType == .mandatory, "Unexpected Configuration UpdateType")
                XCTAssertTrue(state.contextualUpdateType == .mandatory, "Unexpected contextual UpdateType")
            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }

    func testDiscardedUpdate() {

        let response = [
            "urlConfig": [
                "key": "value"
            ],
            "appUpdate": [
                "availableVersion": "4.5.6",
                "url": "http://nohost.com",
                "type": "recommended",
                "frequency": "once",
                "localizedStrings": [
                    [
                        "title": "title",
                        "text": "message",
                        "options": [
                            [
                                "title": "update",
                                "isUpdateAction": true
                            ]
                        ]
                    ]
                ]
            ]
        ].data()

        // failure callback must not be executed; Test should fail in that case
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "Configuration cache not empty")

        let provider = TestProvider(response: response)
        manager.request(using: provider, with: DefaultDeserializer(), completion: { [weak self] result in

            guard let this = self else {
                XCTFail("Reference to 'self' is nil")
                return
            }

            switch result {
            case let .success(state):
                // validate completion is called with expected configuration
                XCTAssertTrue(state.configuration.appUpdate.updateType == .recommended, "Unexpected Configuration UpdateType")
                XCTAssertTrue(state.contextualUpdateType == .recommended, "Unexpected contextual UpdateType")

                // simulate discarded update
                this.manager.discardRecommendedUpdate(for: state.configuration.appUpdate)
                this.manager.request(using: provider, with: DefaultDeserializer(), completion: { result in
                    switch result {
                    case let .success(state):
                        // validate completion is called with expected configuration
                        XCTAssertTrue(state.configuration.appUpdate.updateType == .recommended, "Unexpected Configuration UpdateType")
                        XCTAssertTrue(state.contextualUpdateType == .discarded, "Unexpected contextual UpdateType")
                    case let .failure(error):
                        XCTFail("Unexpected failure result: \(error)")
                    }
                })

            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }

    func testOriginCache() {

        let response = [
            "urlConfig": [
                "key": "value"
            ],
            "appUpdate": [
                "availableVersion": "1.2.1",
                "url": "http://nohost.com",
                "type": "ignore"
            ]
        ].data()

        // load valid configuration; will be written to confifguration cache
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "ConfigurationCache not empty")

        let provider = TestProvider(response: response)
        manager.request(using: provider, with: DefaultDeserializer(), completion: { [weak self] (result) in

            guard let this = self else {
                XCTFail("Reference to 'self' is nil")
                return
            }

            switch result {
            case .success(_):

                // ensure cache is filled
                XCTAssertNotNil(this.manager.cache.lastLoadedConfiguration, "ConfigurationCache empty")

                // force provider request error; this should read previous configuration from cache
                let provider = TestProvider(error: .provider(message: "TestProvider forced error"))

                // make sure cache is being used and start new request
                this.manager.ignoreCache = false
                this.manager.request(using: provider, with: DefaultDeserializer(), completion: { result in
                    switch result {
                    case let .success(state):
                        XCTAssertTrue(state.configuration.appUpdate.updateType == .ignore, "Unexpected Configuration UpdateType")
                        XCTAssertTrue(state.contextualUpdateType == .ignore, "Unexpected contextual UpdateType")
                    case let .failure(error):
                        XCTFail("Unexpected failure result: \(error)")
                    }
                })

            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }

    func testOriginBundle() {

        // ignore cache and configure bundled config file
        manager.clearCache()
        XCTAssertNil(manager.cache.lastLoadedConfiguration, "ConfigurationCache not empty")
        manager.ignoreCache = true
        manager.configurationBundle = Bundle.module
        manager.configurationBundleFilename = "ignoreUpdate.json"

        // force provider request error; this should read previous configuration from cache
        let provider = TestProvider(error: .provider(message: "TestProvider forced Error"))
        manager.request(using: provider, with: DefaultDeserializer(), completion: { result in

            switch result {
            case let .success(state):
                XCTAssertTrue(state.configuration.appUpdate.updateType == .ignore, "Unexpected Configuration UpdateType")
                XCTAssertTrue(state.contextualUpdateType == .ignore, "Unexpected contextual UpdateType")
            case let .failure(error):
                XCTFail("Unexpected failure result: \(error)")
            }
        })
    }
}

// MARK: - Helper classes

/// Request to be used as a fake `request` within all tests. It returns instantly and can not be cancelled.
class TestRequest: Request {
    func cancel() { /* empty implementation */ }
}

/// Provider to be used throughout all tests
class TestProvider: Provider {

    /// Defines the result of the provider request, which either succeeds or fails, depending on the initializer used.
    private enum Result {
        case success(Data)
        case failure(RemoteConfiguration.Error)
    }

    /// The result given by the initializer.
    private var result: Result

    /// Initializes a new instance of `Self`, which fails all requests with given `error`.
    init(error: RemoteConfiguration.Error) {
        result = .failure(error)
    }

    /// Initializes a new instance of `Self`, which finishes all requests successfully with given `data`.
    init(response: Data) {
        result = .success(response)
    }

    /// Executes the success or failure closure immediatelly (depending on the initializer) used and returns a plain request object.
    func request(with url: URL, success: @escaping (Data) -> Void, failure: @escaping (RemoteConfiguration.Error) -> Void) -> Request {

        switch result {
        case let .success(response):
            success(response)
        case let .failure(error):
            failure(error)
        }
        return TestRequest()
    }
}
