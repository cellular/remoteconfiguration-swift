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