//
//  File.swift
//  
//
//  Created by Sven Jansen on 25.05.22.
//

import XCTest
@testable import RemoteConfiguration

class DefaultUpdateHandlerTests: XCTestCase {

    let manager = Manager(url: URL(string: "https://www.myApi.com")!)

    func testIngoreForSingleMajorVersion() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1.3",
                                                      ignoredVersions: ["12"])
        XCTAssertTrue(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForSingleMajorVersionNotIncluded() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "13.4",
                                                      ignoredVersions: ["12"])
        XCTAssertFalse(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForSingleMinorVersion() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1.3",
                                                      ignoredVersions: ["12.1"])
        XCTAssertTrue(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForSingleMinorVersionNotIncluded() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.2",
                                                      ignoredVersions: ["12.1"])
        XCTAssertFalse(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForMultipleMajorVersions() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1.3", ignoredVersions: ["12", "13", "14"])
        XCTAssertTrue(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForMultipleMajorVersionsNotIncluded() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "15.4.1",

                                                      ignoredVersions: ["12", "13", "14"])
        XCTAssertFalse(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForMultipleMinorVersions() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1.3",
                                                      ignoredVersions: ["12.1", "13.3", "14.1.2"])
        XCTAssertTrue(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testIngoreForMultipleMinorVersionsNotIncluded() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1",
                                                      ignoredVersions: ["12.1.3", "13.3", "14.1.2"])
        XCTAssertFalse(DefaultUpdateHandler(manager: manager).canMandatoryUpdateBeIgnored(for: mandatoryVersioning))
    }

    func testUpdateAvailableIgnored() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1",
                                                      ignoredVersions: ["12.1", "13.3", "14.1.2"])
        let updateContext = UpdateContext(updateUrl: "https://itunes.com/niceApp123",
                                          availableVersion: "2.0",
                                          alertFrequency: .always,
                                          updateType: .mandatory,
                                          mandatoryVersioning: mandatoryVersioning,
                                          localizedAlerts: [UpdateAlert(languageCode: "de",
                                                                        regionCode: "de",
                                                                        title: "Update verfügbar",
                                                                        text: "Alles neu!",
                                                                        options: [])])
        let expectation = expectation(description: "\(#function)\(#line)")
        DefaultUpdateHandler(manager: manager).updateAvailable(updateType: .mandatory,
                                                               mandatoryVersioning: mandatoryVersioning,
                                                               updateContext: updateContext,
                                                               presentingViewController: UIViewController()) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUpdateAvailableNotIgnored() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12.1",
                                                      ignoredVersions: ["12.1.3", "13.3", "14.1.2"])
        let updateContext = UpdateContext(updateUrl: "https://itunes.com/niceApp123",
                                          availableVersion: "2.0",
                                          alertFrequency: .always,
                                          updateType: .mandatory,
                                          mandatoryVersioning: mandatoryVersioning,
                                          localizedAlerts: [UpdateAlert(languageCode: "de",
                                                                        regionCode: "de",
                                                                        title: "Update verfügbar",
                                                                        text: "Alles neu!",
                                                                        options: [])])
        let expectation = expectation(description: "\(#function)\(#line)")
        expectation.isInverted = true
        DefaultUpdateHandler(manager: manager).updateAvailable(updateType: .mandatory,
                                                               mandatoryVersioning: mandatoryVersioning,
                                                               updateContext: updateContext,
                                                               presentingViewController: UIViewController()) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUpdateAvailableNotIgnoredNotMandatory() {
        let mandatoryVersioning = MandatoryVersioning(systemVersion: "12",
                                                      ignoredVersions: ["12"])
        let updateContext = UpdateContext(updateUrl: "https://itunes.com/niceApp123",
                                          availableVersion: "2.0",
                                          alertFrequency: .always,
                                          updateType: .recommended,
                                          mandatoryVersioning: mandatoryVersioning,
                                          localizedAlerts: [UpdateAlert(languageCode: "de",
                                                                        regionCode: "de",
                                                                        title: "Update verfügbar",
                                                                        text: "Alles neu!",
                                                                        options: [])])
        let expectation = expectation(description: "\(#function)\(#line)")
        expectation.isInverted = true
        DefaultUpdateHandler(manager: manager).updateAvailable(updateType: .recommended,
                                                               mandatoryVersioning: mandatoryVersioning,
                                                               updateContext: updateContext,
                                                               presentingViewController: UIViewController()) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

