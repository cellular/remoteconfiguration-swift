import Foundation
import RemoteConfiguration

public class CustomJSONDeserializer: Deserializer {

    public func deserialize(from data: Data, with origin: Origin, context: UpdateContext) throws -> CustomConfiguration {
        return try CustomConfiguration(data: data, origin: origin, context: context)
    }
}
