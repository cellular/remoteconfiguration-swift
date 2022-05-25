# RemoteConfiguration

[![Build Status](https://travis-ci.com/cellular/remoteconfiguration-swift.svg?branch=master)](https://travis-ci.com/cellular/remoteconfiguration-swift)
[![Codecov](https://codecov.io/gh/cellular/remoteconfiguration-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/cellular/remoteconfiguration-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CellularRemoteConfiguration.svg)](https://cocoapods.org/pods/cellularremoteconfiguration)
[![Swift Version](https://img.shields.io/badge/swift-4.2-orange.svg)](https://swift.org)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)

Dynamic configuration of iOS, tvOS or watchOS application using remote files.

## Usage

TODO

## Examples for the different update types

### Optional Update: Optionally show alert

```json
{
    "customKey1": "customValue1",
    "customKey2": "customValue2",
    "customKey3": "customValue3",

    "urlConfig": {
        "baseUrl": "http://some.host.com/api/"
    },

    "appUpdate": {
        "availableVersion": "1.2.3",
        "url": "https://itunes.apple.com/app",
        "type": "ignore"
    }
}
```

### Recommended Update: Always show alert, allow skip

```json
{
    "customKey1": "customValue1",
    "customKey2": "customValue2",
    "customKey3": "customValue3",

    "urlConfig": {
        "baseUrl": "http://some.host.com/api/"
    },

    "appUpdate": {
        "availableVersion": "1.2.3",
        "url": "https://itunes.apple.com/theApp",
        "type": "recommended",
        "frequency": "always",
        "localizedStrings": [
            {
                "languageCode": "de",
                "regionCode": "DE",
                "title": "Aktualisierung verfügbar",
                "text": "Es steht eine empfohlene Aktualisierung zur Verfügung. Möchten sie diese jetzt installieren?",
                "options": [
                    {
                        "title": "Nein"
                    },
                    {
                        "title": "Aktualisieren",
                        "isUpdateAction": true
                    }
                ]
            }
        ]
    }
}
```

### Recommended Update, show alert only once

```json
{
    "customKey1": "customValue1",
    "customKey2": "customValue2",
    "customKey3": "customValue3",

    "urlConfig": {
        "baseUrl": "http://some.host.com/api/"
    },

    "appUpdate": {
        "availableVersion": "1.2.3",
        "url": "https://itunes.apple.com/theApp",
        "type": "recommended",
        "frequency": "once",
        "localizedStrings": [
            {
                "languageCode": "de",
                "regionCode": "DE",
                "title": "Aktualisierung verfügbar",
                "text": "Es steht eine empfohlene Aktualisierung zur Verfügung. Möchten sie diese jetzt installieren?",
                "options": [
                    {
                        "title": "Nein"
                    },
                    {
                        "title": "Aktualisieren",
                        "isUpdateAction": true
                    }
                ]
            }
        ]
    }
}
```

### Mandatory Update

```json
{
    "customKey1": "customValue1",
    "customKey2": "customValue2",
    "customKey3": "customValue3",

    "urlConfig": {
        "baseUrl": "http://some.host.com/api/"
    },

    "appUpdate": {
        "availableVersion": "1.2.3",
        "url": "https://itunes.apple.com/theApp",
        "type": "mandatory",
        "ignoredOSVersions": [
            "12"
        ],
        "localizedStrings": [
            {
                "languageCode": "de",
                "regionCode": "DE",
                "title": "Aktualisierung verfügbar",
                "text": "Es steht eine benötigte Aktualisierung zur Verfügung.",
                "options": [
                    {
                        "title": "Aktualisieren",
                        "isUpdateAction": true
                    }
                ]
            }
        ]
    }
}
```
## Update for version 7.0.0

The dependency to CellularNetworking has been removed in this version.

The adapter to bind RemoteConfiguration to CellularNetworking has been moved to ```Example/Example/Controller/RemoteConfiguration+Adapter.swift```. This adapter must be copied to the Application to bind RemoteConfiguration to CellularNetworking or any other networking clients like Alamofire or plain NSURLSession.


## Update for version 8.0.0

For mandatory updates it's now possible to ignore one or more iOS versions. iOS Versions contained in the array of "ignoredOSVersions" will not react to mandatory updates until the version is removed from the array. 
This could be useful if you don't support special iOS versions anymore but the last working version should stil exist on the AppStore and should not be disabled by a mandatory update. If there is a breaking API change later on, you still have the ability to remove this version from the list and the mandatory update will be shown as usual.
