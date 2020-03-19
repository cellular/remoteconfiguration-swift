import Foundation

/// A class representing an update option to be displayed to the user if an app update is available.
///
/// **Example:**
/// ```
/// "options": [
///     {
///         "title": "Nein"
///     },
///     {
///         "title": "Aktualisieren",
///         "isUpdateAction": true
///     }
/// ]
/// ```
public struct UpdateOption: Codable, Equatable {

    /// The text to be displayed for the option.
    public let title: String

    /// A boolean indicating if the option defines the 'update' action to be executed when the user selects it.
    public let isUpdateAction: Bool

    /// Creates a new UpdateAction using the specified properties.
    public init(title: String, isUpdateAction: Bool) {
        self.title = title
        self.isUpdateAction = isUpdateAction
    }

    // MARK: Codable

    /// Maps the native properties to their JSON key equivalent for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case title
        case isUpdateAction
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        isUpdateAction = try values.decodeIfPresent(Bool.self, forKey: .isUpdateAction) ?? false
    }
}

extension Sequence where Element == UpdateOption {

    /// - Returns:
    ///     The `UpdateOption` instance within the sequence where `isUpdateAction` is `true`.
    ///      `nil` if the sequence does not contain an update action.
    public func updateActionOption() -> UpdateOption? {
        return first { $0.isUpdateAction }
    }
}
