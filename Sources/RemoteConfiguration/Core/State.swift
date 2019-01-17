import Foundation

public struct State<C: Configuration> {

    public let configuration: C
    public let contextualUpdateType: UpdateType
}
