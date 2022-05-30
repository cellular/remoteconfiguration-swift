import UIKit

/// A class containing information on the Update status for the associated App. Will be created by the Manager during
/// execution of requestConfiguration() using the requested Configuration dictionary.
///
/// **Example:**
/// ```
/// "appUpdate": {
///     "availableVersion": "1.6.0",
///     "type": "ignore",
///     "ignoredOSVersions": [
///         "12",
///         "13.1"
///     ],
///     "url": "https://itunes.apple.com/de/app/tv-spielfilm-tv-programm-mit-live-tv/id346997126?mt=8&at=11l4L8",
///     "localizedStrings": [
///         {
///             "languageCode": "de",
///             "regionCode": "DE",
///             "title": "Aktualisierung verfügbar",
///             "text": "Es steht eine empfohlene Aktualisierung zur Verfügung. Möchten sie diese jetzt installieren?",
///             "options": [
///                 {
///                     "title": "Nein"
///                 },
///                 {
///                     "title": "Aktualisieren",
///                     "isUpdateAction": true
///                 }
///             ]
///         }
///     ]
/// }
/// ```

/// Wrapper which holds information about the current system version and possibly ignored
/// versions for mandatory updates
public struct MandatoryVersioning: Codable, Equatable {
    let systemVersion: String
    let ignoredVersions: [String]

    public init(systemVersion: String = ProcessInfo().operatingSystemVersionString, ignoredVersions: [String]) {
        self.systemVersion = systemVersion
        self.ignoredVersions = ignoredVersions
    }
}

public struct UpdateContext: Codable, Equatable {

    /// The URL to open on update action
    public let updateUrl: String

    /// The version of the available update
    public let availableVersion: String

    /// The frequency with which the update dialog should be presented to the User in case of a recommended update.
    /// Mandatory updates and Ingore updates will have a frequency of 'always', which is the default value.
    /// Once a recommended update with a frequency of 'once' has been discarded by the user, no further dialogs should be presented
    /// for this update version.
    public let alertFrequency: AlertFrequency

    /// The associated update type, i.e. ignore, recommended, mandatory
    public internal(set) var updateType: UpdateType

    /// Information about OS versions, which shouldn't be affected of a madatory update alert
    public let mandatoryVersioning: MandatoryVersioning

    /// The alert (containing title, text and buttons) to be displayed in an update dialog
    public let localizedAlerts: [UpdateAlert]?

    /// Initializes a new UpdateContext with the specified Parameters.
    /// This allows Clients to create a custom Configuration instance manually if required.
    ///
    /// - Parameters:
    ///   - updateUrl: The AppStore URL of the App
    ///   - availableVersion: The latest available version of the App
    ///   - alertFrequency: The frequency in which a 'recommended' update dialog should be presented
    ///   - updateType: The associated update type
    ///   - mandatoryVersioning: information about iOS versions, which should not be affected by a mandatory update
    ///   - localizedAlerts: The alert to be displayed in an update dialog
    public init(updateUrl: String, availableVersion: String, alertFrequency: AlertFrequency,
                updateType: UpdateType, mandatoryVersioning: MandatoryVersioning, localizedAlerts: [UpdateAlert]) {
        self.updateUrl = updateUrl
        self.availableVersion = availableVersion
        self.alertFrequency = alertFrequency
        self.updateType = updateType
        self.mandatoryVersioning = mandatoryVersioning
        self.localizedAlerts = localizedAlerts
    }

    // MARK: Codable

    /// Maps the native properties to their JSON key equivalent for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case updateUrl = "url"
        case updateType = "type"
        case ignoredOSVersions
        case availableVersion
        case localizedAlerts = "localizedStrings"
        case alertFrequency = "frequency"
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)
        updateUrl = try values.decode(String.self, forKey: .updateUrl)
        alertFrequency = try values.decodeIfPresent(AlertFrequency.self, forKey: .alertFrequency) ?? .always
        availableVersion = try values.decode(String.self, forKey: .availableVersion)
        updateType = try values.decodeIfPresent(UpdateType.self, forKey: .updateType) ?? .ignore
        let ignoredOSVersions = try values.decodeIfPresent([String].self, forKey: .ignoredOSVersions) ?? []
        mandatoryVersioning = MandatoryVersioning(ignoredVersions: ignoredOSVersions)

        // Decodes the update options (if any), allowing some to fail. Even none are allowed, if the update type is ignore.
        let optionalAlerts = try values.decodeIfPresent([UpdateAlert?].self, forKey: .localizedAlerts)
        let alerts = optionalAlerts?.compactMap { $0 } // Flatten out nil values within the serialized array

        // Evaluate the update type. Mandatory and recommended updates require alerts to be present.
        switch updateType {
        case .ignore, .discarded: break // No further action evaluation necessary.
        case .recommended, .mandatory: // As of now, the evaluation equals the mandatory evaluation.
            guard let localizedAlert = alerts?.option(forLocale: Locale.current) else {
                throw Error.validation(
                    message: "Recommended and Mandatory updates require at least one update alert with options."
                )
            }
            guard localizedAlert.options.updateActionOption() != nil else {
                throw Error.validation(
                    message: "Recommended and Mandatory updates require their update options to define an update action."
                )
            }
        }

        // Alerts are valid.
        localizedAlerts = alerts
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(updateUrl, forKey: .updateUrl)
        try container.encode(availableVersion, forKey: .availableVersion)
        try container.encode(alertFrequency, forKey: .alertFrequency)
        try container.encode(updateType, forKey: .updateType)
        try container.encode(mandatoryVersioning.ignoredVersions, forKey: .ignoredOSVersions)
        try container.encode(localizedAlerts, forKey: .localizedAlerts)
    }
}
