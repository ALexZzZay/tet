import Foundation

public enum JSONValue {

    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    indirect case object([String: JSONValue])
    indirect case array([JSONValue])
}

extension JSONValue: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let result: JSONValue =
            container.tryDecodeMap(String.self, JSONValue.string) ??
            container.tryDecodeMap(Int.self, JSONValue.int) ??
            container.tryDecodeMap(Double.self, JSONValue.double) ??
            container.tryDecodeMap(Bool.self, JSONValue.bool) ??
            container.tryDecodeMap([String: JSONValue].self, JSONValue.object) ??
            container.tryDecodeMap([JSONValue].self, JSONValue.array) {
            self = result
            return
        }
        if container.decodeNil() {
            self = JSONValue.null
            return
        }
        throw DecodingError.typeMismatch(
            JSONValue.self,
            DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON")
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}

public extension JSONValue {

    var string: String? {
        guard case let .string(value) = self else {
            return nil
        }
        return value
    }

    var int: Int? {
        guard case let .int(value) = self else {
            return nil
        }
        return value
    }

    var double: Double? {
        guard case let .double(value) = self else {
            return nil
        }
        return value
    }

    var bool: Bool? {
        guard case let .bool(value) = self else {
            return nil
        }
        return value
    }

    var isNull: Bool {
        guard case .null = self else {
            return false
        }
        return true
    }

    var object: [String: JSONValue]? {
        guard case let .object(value) = self else {
            return nil
        }
        return value
    }

    var array: [JSONValue]? {
        guard case let .array(value) = self else {
            return nil
        }
        return value
    }
}

private extension SingleValueDecodingContainer {

    func tryDecodeMap<T, V>(_ type: T.Type, _ map: (T) -> V) -> V? where T: Decodable {
        do {
            let raw = try decode(type)
            return map(raw)
        } catch {
            return nil
        }
    }
}
