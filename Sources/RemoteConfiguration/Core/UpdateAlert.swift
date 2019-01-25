import Foundation

/// **Example:**
/// ```
/// {
///     "languageCode": "de",
///     "regionCode": "DE",
///     "title": "Aktualisierung verfügbar",
///     "text": "Es steht eine empfohlene Aktualisierung zur Verfügung. Möchten sie diese jetzt installieren?",
///     "options": [
///         {
///             "title": "Nein"
///         },
///         {
///             "title": "Aktualisieren",
///             "isUpdateAction": true
///         }
///     ]
/// }
/// ```
public struct UpdateAlert: Codable {

    /// The language code of the localized strings within `self` (e.g. "en")
    public let languageCode: String?

    /// The region code of the localized strings within `self` (e.g. "US")
    public let regionCode: String?

    /// The title to be displayed within an update dialog (localized).
    public let title: String

    /// The text to be displayed as message within an update dialog (localized).
    public let text: String

    /// The options to be chosen by the user within the update dialog (e.g. trigger update or skip update)
    public let options: [UpdateOption]
}

extension Collection where Element == UpdateAlert {

    /// The localized alert values that matches given locale the best.
    /// Priority as to how well the alert matches the local is defined by:
    /// 1. Language & Region match
    /// 2. Language matches
    /// 3. First in the collection
    ///
    /// - Parameter locale: The locale to match against the localized alert within the collection.
    /// - Returns: The localized alert that matches given locale the best.
    public func option(forLocale locale: Locale) -> Element? {

        // Find best matching locale; matching is priorized by language & country -> language -> first in list
        let targetLanguage = locale.languageCode ?? "en"
        let targetRegion = locale.regionCode

        // Try to find and return exact language & region match and/or find language match (`bestMatch`)
        var languageMatch: UpdateAlert?
        for option in self where option.languageCode == targetLanguage {
            if let region = option.regionCode, region == targetRegion {
                return option // found exact language/region match
            }
            languageMatch = option
        }

        // Returns best match by language or the first element in the list, if no language matches.
        return languageMatch ?? first
    }
}
