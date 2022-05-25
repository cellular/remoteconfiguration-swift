import XCTest
@testable import RemoteConfiguration

class UpdateContextTests: XCTestCase {

    private let availableVersion = "1.2.3"
    private let updateUrl = "http://nohost.com"
    private var languageCode: String { return Locale.current.languageCode ?? "en" }
    private var regionCode: String { return Locale.current.regionCode ?? "US" }
    private let ignoreOSVersions = ["12", "13.1"]

    // MARK: - Ignore Update

    func testNoneContext() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "ignore"
            ]
        ]

        // create update context
        let updateContext: UpdateContext
        do {
            updateContext = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate

        } catch let error as RemoteConfiguration.Error {
            switch error {
            case .provider(let message), .deserializer(let message), .validation(let message):
                XCTFail("UpdateContext could not be initialized: \(message)")
            }
            return
        } catch let error {
            XCTFail("UpdateContext could not be initialized: \(error.localizedDescription)")
            return
        }

        // check update context properties
        XCTAssert(updateContext.updateUrl == updateUrl, "Unexpected value for key 'url'")
        XCTAssert(updateContext.updateType == .ignore, "Unexpected UpdateType")
    }

    func testIgnoreContext() {

        let updateVersion = "1.2.4"
        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": updateVersion,
                "url": updateUrl,
                "type": "ignore"
            ]
        ]

        // create update context
        let updateContext: UpdateContext
        do {
           updateContext = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate

        } catch let error as RemoteConfiguration.Error {
            switch error {
            case .provider(let message), .deserializer(let message), .validation(let message):
                XCTFail("UpdateContext could not be initialized: \(message)")
            }
            return
        } catch let error {
            XCTFail("UpdateContext could not be initialized: \(error.localizedDescription)")
            return
        }

        // check update context properties
        XCTAssert(updateContext.updateUrl == updateUrl, "Unexpected value for key 'url'")
        XCTAssert(updateContext.updateType == .ignore, "Unexpected UpdateType")
    }

    func testIgnoreContextMissingUrl() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "type": "ignore"
            ]
        ]

        // try to create update context from invalid configuration
        do {
            _ = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
            XCTFail("UpdateContext was created from invalid Configuration")
        } catch let error {
            guard case let .keyNotFound(codingKey, _)? = error as? DecodingError,
                let updateContextKey = codingKey as? UpdateContext.CodingKeys else {

                    XCTFail("Unexpected Error type")
                return
            }
            XCTAssertTrue(updateContextKey == UpdateContext.CodingKeys.updateUrl , "Unexpected coding error")
        }
    }

    func testIgnoreContextMissingType() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl
            ]
        ]

        do {
            // Create update context. If update type is missing, initializer of UpdateContext will set update type tp '.ignore'.
            let context  = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
            XCTAssertTrue(context.updateType == .ignore, "Unexpected update type")
        } catch let  error {
            XCTFail("Unexpected Error type: \(error)")
        }
    }

    // MARK: Recommended Update

    func testRecommendedContext() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "recommended",
                "localizedStrings": [
                    [
                        "languageCode": languageCode,
                        "title": "title_\(languageCode)",
                        "text": "text_\(languageCode)",
                        "options": [
                            [
                                "title": "button_ok_\(languageCode)"
                            ],
                            [
                                "title": "button_update_\(languageCode)",
                                "isUpdateAction": true
                            ]
                        ]
                    ],
                    [
                        "languageCode": languageCode,
                        "regionCode": regionCode,
                        "title": "title_\(languageCode)_\(regionCode)",
                        "text": "message_\(languageCode)_\(regionCode)",
                        "options": [
                            [
                                "title": "button_ok_\(languageCode)_\(regionCode)"
                            ],
                            [
                                "title": "button_update_\(languageCode)_\(regionCode)",
                                "isUpdateAction": true
                            ]
                        ]
                    ]
                ]
            ]
        ]

        // create update context
        let updateContext: UpdateContext
        do {
            updateContext = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
        } catch let rcError as RemoteConfiguration.Error {
            switch rcError {
            case .provider(let message), .deserializer(let message), .validation(let message):
                XCTFail("UpdateContext could not be initialized: \(message)")
            }
            return
        } catch let error {
            XCTFail("UpdateContext could not be initialized: \(error.localizedDescription)")
            return
        }

        // check update context properties

        XCTAssert(updateContext.updateUrl == updateUrl, "Unexpected value for key 'url'")
        XCTAssert(updateContext.updateType == .recommended, "Unexpected UpdateType")
        XCTAssert(updateContext.localizedAlerts?.count == 2, "Unexpected number of update alerts")
        XCTAssert(updateContext.localizedAlerts?[0].options.count == 2, "Unexpected number of update options")

        // Alert 1
        XCTAssert(updateContext.localizedAlerts?[0].title == "title_\(languageCode)", "Unexpected alert title")
        XCTAssert(updateContext.localizedAlerts?[0].regionCode == nil, "Unexpected regional code")
        XCTAssert(updateContext.localizedAlerts?[0].options[0].title == "button_ok_\(languageCode)", "Unexpected OK option title")
        XCTAssert(updateContext.localizedAlerts?[0].options[0].isUpdateAction == false, "Unexpected update action")
        XCTAssert(updateContext.localizedAlerts?[0].options[1].title == "button_update_\(languageCode)", "Unexpected OK option title")
        XCTAssert(updateContext.localizedAlerts?[0].options[1].isUpdateAction == true, "Unexpected update action")

        // Alert 2
        XCTAssert(updateContext.localizedAlerts?[1].title == "title_\(languageCode)_\(regionCode)", "Unexpected alert title")
        XCTAssert(updateContext.localizedAlerts?[1].regionCode == regionCode, "Unexpected regional code")
        XCTAssert(updateContext.localizedAlerts?[1].options[0].title == "button_ok_\(languageCode)_\(regionCode)", "Unexpected OK option title")
        XCTAssert(updateContext.localizedAlerts?[1].options[0].isUpdateAction == false, "Unexpected update action")
        XCTAssert(updateContext.localizedAlerts?[1].options[1].title == "button_update_\(languageCode)_\(regionCode)", "Unexpected OK option title")
        XCTAssert(updateContext.localizedAlerts?[1].options[1].isUpdateAction == true, "Unexpected update action")
    }

    func testMandatoryContext() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "mandatory",
                "localizedStrings": [
                    [
                        "languageCode": languageCode,
                        "title": "title_\(languageCode)",
                        "text": "text_\(languageCode)",
                        "options": [
                            [
                                "title": "title_ok_\(languageCode)"
                            ],
                            [
                                "title": "title_update_\(languageCode)",
                                "isUpdateAction": true
                            ]
                        ]
                    ]
                ]
            ]
        ]

        // create update context
        let updateContext: UpdateContext
        do {
            updateContext = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
        } catch let rcError as RemoteConfiguration.Error {
            switch rcError {
            case .provider(let message), .deserializer(let message), .validation(let message):
                XCTFail("UpdateContext could not be initialized: \(message)")
            }
            return
        } catch let error {
            XCTFail("UpdateContext could not be initialized: \(error.localizedDescription)")
            return
        }

        // check update context properties
        XCTAssert(updateContext.updateUrl == updateUrl, "Unexpected value for key 'url'")
        XCTAssert(updateContext.updateType == .mandatory, "Unexpected UpdateType")
        XCTAssert(updateContext.localizedAlerts?.count == 1, "Unexpected number of alerts")
        XCTAssert(updateContext.localizedAlerts?[0].options.count == 2, "Unexpected number of update options")
        XCTAssert(updateContext.localizedAlerts?[0].options[0].title == "title_ok_\(languageCode)", "Unexpected Update option title")
        XCTAssert(updateContext.localizedAlerts?[0].options[0].isUpdateAction == false, "Unexpected update action")
        XCTAssert(updateContext.localizedAlerts?[0].options[1].title == "title_update_\(languageCode)", "Unexpected Update option title")
        XCTAssert(updateContext.localizedAlerts?[0].options[1].isUpdateAction == true, "Unexpected update action")
    }

    func testMandatoryContextMissingLocalizedStrings() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "mandatory"
            ]
        ]

        // try to create update context from invalid configuration (missing localized strings)
        do {
            _ = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
            XCTFail("UpdateContext was created from invalid Configuration")
        } catch let error {
            XCTAssert(error is RemoteConfiguration.Error, "Unexpected Error type")
        }
    }

    func testMandatoryContextMissingUpdateOptions() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "mandatory",
                "localizedStrings": [
                    [
                        "title": "title",
                        "text": "text"
                    ]
                ]
            ]
        ]

        // try to create update context from invalid configuration (missing update options)
        do {
            _ = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
            XCTFail("UpdateContext was created from invalid Configuration")
        } catch let error {
            if case RemoteConfiguration.Error.validation(message: _)? = error as? RemoteConfiguration.Error {
                XCTFail("Unexpected Error type")
            }
        }
    }

    func testMandatoryContextMissingUpdateAction() {

        let configuration: [String : Any] = [
            "appUpdate" : [
                "availableVersion": availableVersion,
                "url": updateUrl,
                "type": "mandatory",
                "localizedStrings": [
                    [
                        "title": "title",
                        "text": "message",
                        "options": [
                            [
                                "title": "option_1"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        // try to create update context from invalid configuration (missing update action)
        do {
            _ = try DefaultDeserializer().deserialize(from: configuration.data()).appUpdate
            XCTFail("UpdateContext was created from invalid Configuration")
        } catch let error {
            XCTAssert(error is RemoteConfiguration.Error, "Unexpected Error type")
        }
    }
}
