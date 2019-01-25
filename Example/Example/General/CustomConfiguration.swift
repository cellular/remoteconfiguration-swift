import Foundation
import RemoteConfiguration
import Unbox

public final class CustomConfiguration: Configuration {
    public var updateContext: UpdateContext
    public var origin: Origin
    public var configFile: ConfigFile

    internal init(data: Data, origin: Origin, context: UpdateContext) throws {
        self.origin = origin
        self.updateContext = context
        self.configFile = try unbox(data: data)
    }
}
