import RemoteConfiguration

struct DefaultConfiguration: Configuration, Decodable {
    var appUpdate: UpdateContext
}
