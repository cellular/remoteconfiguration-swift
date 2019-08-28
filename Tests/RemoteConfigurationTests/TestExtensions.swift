import Foundation

extension Sequence where Iterator.Element == (key: String, value: Any) {

    func data() -> Data {
        return (try? JSONSerialization.data(withJSONObject: self, options: [])) ?? Data()
    }
}

extension Data {

    func json() -> [String : Any] {

        var result: [String : Any] = [:]

        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: []) as? [String : Any] {
                result = json
            }
        } catch { }

        return result
    }
}
