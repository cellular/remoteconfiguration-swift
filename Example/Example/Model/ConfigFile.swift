import Foundation
import Unbox

public struct ConfigFile {
    let urlConfig: JSONDict
    let appUpdate: JSONDict
}

extension ConfigFile: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.urlConfig = try unboxer.unbox(key: "urlConfig")
        self.appUpdate = try unboxer.unbox(key: "appUpdate")
    }
}
