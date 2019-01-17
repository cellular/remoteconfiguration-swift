import Foundation

/// Protocol defining the required functions for a Deserializer implementation used by the ConfigurationManager.
/// A Deserializer is responsible to create a Configuration instance from the JSON dictionary requested by the associated Provider.
public protocol Deserializer {

    /// The associated type to be used by the Deserializer implementation as the concrete Model class
    associatedtype Model: Configuration

    /// Deserializes and returns an instance of a Configuration implementation using the specified data representing a JSON dictionary.
    /// - Parameter from: the data to be used for deserialization
    /// - Returns: a Configuration instance
    /// - Throws: RemoteConfiguration.Error if deserialization failed
    func deserialize(from data: Data) throws -> Model
}
