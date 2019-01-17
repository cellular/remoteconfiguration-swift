import Foundation

/// Enumeration defining the different errors handled by the ConfigurationManager.
///
/// - provider: Error related to the data Provider.
/// - deserializer: Error related to the Deserializer.
/// - validation: Error related to validating the Configuration data.
public enum Error: Swift.Error {
    case provider(message: String)
    case deserializer(message: String)
    case validation(message: String)
}
