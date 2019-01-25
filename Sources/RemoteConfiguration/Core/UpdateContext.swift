import Foundation

/// A class containing information on the Update status for the associated App. Will be created by the Manager during
/// execution of requestConfiguration() using the requested Configuration dictionary.
///
/// **Example:**
/// ```
/// "appUpdate": {
///     "availableVersion": "1.6.0",
///     "type": "ignore",
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
public struct UpdateContext: Codable {

    /// The URL to open on update action
    public let updateUrl: String

    /// The version of the available update
    public let availableVersion: String

    /// The frequency in which the update dialog should be presented to the User in case of a recommended update.
    /// Mandatory updates and Ingore updates will have a frequency of 'always', which is the default value.
    /// Once a recommended update with a frequency of 'once' has been discarded by the user, no further dialogs should be presented
    /// for this update version.
    public let alertFrequency: AlertFrequency

    /// The associated update type, i.e. ignore, recommended, mandatory
    public internal(set) var updateType: UpdateType

    /// The alert (containing title, text and buttons) to be displayed in an update dialog
    public let localizedAlerts: [UpdateAlert]?

    /// Maps the native properties to their JSON key equivalent for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case updateUrl = "url"
        case updateType = "type"
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
}
