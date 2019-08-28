import Foundation
import RemoteConfiguration

final class DefaultDeserializer: Deserializer {

    init() {}

    func deserialize(from data: Data) throws -> DefaultConfiguration {
       return try JSONDecoder().decode(DefaultConfiguration.self, from: data)
    }
}
