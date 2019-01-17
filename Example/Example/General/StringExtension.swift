import Foundation

extension String {

    public static func fromJSONObject(object: AnyObject) -> String? {
        do {
            let JSONData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            return String(data: JSONData, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
