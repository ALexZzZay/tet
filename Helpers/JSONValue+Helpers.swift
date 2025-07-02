import Foundation

// MARK: - Codable helpers

extension JSONValue {

    static func fromData(_ data: Data) -> Self {
        let decoder = JSONDecoder()
        let json = try? decoder.decode(JSONValue.self, from: data)
        return json!
    }

    static func fromString(_ string: String) -> Self {
        let data = string.data(using: .utf8)
        return fromData(data!)
    }

    static func toData(_ json: Self) -> Data {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(json)
        return data!
    }

    static func toString(_ json: Self) -> String {
        let data = toData(json)
        let string = String(data: data, encoding: .utf8)
        return string!
    }
}

// MARK: - Editing helpers

extension JSONValue {

    subscript(objectValue key: String) -> JSONValue? {
        get {
            self.object?[key]
        }
        set {
            self.editObject { object in
                object[key] = newValue
            }
        }
    }

    mutating func editObject(_ edit: (inout [String: JSONValue]) -> Void) {
        var object = self.object!
        edit(&object)
        self = .object(object)
    }

    mutating func editArray(_ edit: (inout [JSONValue]) -> Void) {
        var array = self.array!
        edit(&array)
        self = .array(array)
    }

    mutating func editArrayInPlace(_ edit: (inout JSONValue) -> Void) {
        editArray { array in
            array.mapInPlace(edit)
        }
    }
}

// MARK: - Foundation editing helpers

extension Array {

    mutating func mapInPlace(_ edit: (inout Element) -> Void) {
        self = self.map { element in
            var newElement = element
            edit(&newElement)
            return newElement
        }
    }
}
