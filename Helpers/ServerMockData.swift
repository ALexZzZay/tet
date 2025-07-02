import Foundation
import APICore

struct ServerMockData {

    /// Example with templates: https://domain.com/some/:firstName/path/:lastName
    let urlTemplate: String
    let handler: Handler

    struct Handler {
        struct Request {
            var request: URLRequest
            var params: [String: String]

            var method: String? { request.httpMethod }
            var httpBody: Data? { request.httpBody }
        }

        struct Response {
            var data: Data?
            var response: HTTPURLResponse
        }

        let run: (Request, @escaping @Sendable (Response) -> Void) -> Void
    }
}

// Shorthands for popular cases
extension ServerMockData.Handler {

    init(run: @escaping (Request) -> Response) {
        self.init { request, completion in
            let result = run(request)
            completion(result)
        }
    }

    static func live<T: Codable>(modify: @escaping @Sendable (T) -> T) -> Self {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(.iso8601DateTimeFormatter)

        return .live(modify: { (response: Response) in
            do {
                let originalDTO: T = try ParseFunc.decodable().run(response.data!)
                let editedDTO = modify(originalDTO)
                let data = try jsonEncoder.encode(editedDTO)

                let urlResponse = response.response.modifyingHeaderFields {
                    $0["Content-Length"] = String(data.count)
                    $0.removeValue(forKey: "Content-Encoding")
                }
                return .init(data: data, response: urlResponse)
            } catch {
                XCTFail("live(modify:) failed: \(error)")
                return .internalServerError(nil)
            }
        })
    }

    static func live(modify: @escaping @Sendable (Response) -> Response) -> Self {
        .init { request, completion in
            Task {
                do {
                    var req = request.request
                    req.setValue(nil, forHTTPHeaderField: "X-Original-URL")

                    let (data, response) = try await URLSession.shared.data(for: req)
                    let urlResponse = response as! HTTPURLResponse
                    let modifiedResponse = modify(Response(data: data, response: urlResponse))
                    completion(modifiedResponse)
                } catch {
                    XCTFail("live(modify:) failed: \(error)")
                    completion(.internalServerError(nil))
                }
            }
        }
    }

    static func ok(jsonFile: String, bundle: Bundle? = nil) -> Self {
        .init { _ in
            if let bundle = bundle {
                return .ok(.jsonFile(jsonFile, bundle: bundle))
            } else {
                return .ok(.jsonFile(jsonFile))
            }
        }
    }

    static func ok(file: String, contentType: String, bundle: Bundle? = nil) -> Self {
        .init { _ in
            let data = BundleHelper.loadData(file, bundle: bundle)
            return .ok(.data(data, contentType: contentType))
        }
    }

    static func ok(json: Any) -> Self {
        .init { _ in
            .ok(.json(json))
        }
    }

    static func ok(jsonString: String) -> Self {
        .init { _ in
            .ok(.jsonString(jsonString))
        }
    }

    static func internalServerError() -> Self {
        .init { _ in
            .internalServerError(nil)
        }
    }

    static func response(statusCode: StatusCode, data: Data?, headerFields: [String: String]? = nil) -> Self {
        .init { _ in
            .response(statusCode: statusCode, data: data, headerFields: headerFields)
        }
    }

    static func withJSONRequestBody(process: @escaping (_ request: Request, _ json: JSONValue) -> Response) -> Self {
        .init { request in
            let json = JSONValue.fromRequestBody(request.httpBody)
            return process(request, json)
        }
    }
}

extension ServerMockData {

    func isValid() -> Bool {
        guard let url = URL(string: urlTemplate) else {
            XCTFail("Invalid URL template format: \(urlTemplate)")
            return false
        }
        guard url.host != nil, url.scheme != nil else {
            XCTFail("scheme and host must be present: \(url)")
            return false
        }
        guard url.fragment == nil else {
            XCTFail("URL must not contain #fragment")
            return false
        }
        return true
    }
}

extension ServerMockData.Handler.Response {

    private static let placeholderUrl = URL(string: "http://localhost")!

    static func ok(_ body: HttpResponseBody) -> Self {
        .response(statusCode: .ok, data: body.data, headerFields: ["content-type": body.contentType])
    }

    static func internalServerError(_ data: Data?) -> Self {
        .response(statusCode: .internalServerError, data: data)
    }

    static func notAcceptable(_ data: Data?) -> Self {
        .response(statusCode: .notAcceptable, data: data)
    }

    static func response(statusCode: StatusCode, data: Data?, headerFields: [String: String]? = nil) -> Self {
        let response = HTTPURLResponse(
            url: placeholderUrl,
            statusCode: statusCode.code,
            httpVersion: nil,
            headerFields: headerFields
        )
        return .init(data: data, response: response!)
    }
}

struct HttpResponseBody {
    let data: Data
    let contentType: String

    static func data(_ data: Data, contentType: String) -> Self {
        .init(data: data, contentType: contentType)
    }

    private static let jsonContentType = "application/json"

    static func jsonString(_ string: String) -> Self {
        let data = string.data(using: .utf8)!
        return .data(data, contentType: jsonContentType)
    }

    static func jsonFile(_ filePath: String, bundle: Bundle? = nil) -> Self {
        let data = BundleHelper.loadData(filePath, bundle: bundle)
        return .data(data, contentType: jsonContentType)
    }

    static func jsonValue(_ json: JSONValue) -> Self {
        let data = JSONValue.toData(json)
        return .data(data, contentType: jsonContentType)
    }

    static func json(_ object: Any) -> Self {
        guard JSONSerialization.isValidJSONObject(object) else {
            XCTFail("Invalid json: \(object)")
            return .jsonString("error")
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: object)
            return .data(data, contentType: jsonContentType)
        } catch {
            XCTFail("Invalid json: \(error)")
            return .jsonString("error")
        }
    }
}

enum StatusCode {
    case ok
    case noContent
    case notModified
    case notFound
    case notAcceptable
    case internalServerError
    case other(code: Int)

    var code: Int {
        switch self {
        case .ok: return 200
        case .noContent: return 204
        case .notModified: return 304
        case .notFound: return 404
        case .notAcceptable: return 406
        case .internalServerError: return 500
        case .other(let code): return code
        }
    }

    var message: String {
        HTTPURLResponse.localizedString(forStatusCode: code)
    }

    var description: String {
        "\(code) \(message)"
    }
}

// MARK: - Helpers

private extension JSONValue {

    static func fromRequestBody(_ array: [UInt8]) -> Self {
        let string = String(bytes: array, encoding: .utf8)
        return fromString(string!)
    }

    static func fromRequestBody(_ data: Data?) -> Self {
        let string = String(data: data!, encoding: .utf8)
        return fromString(string!)
    }
}

private extension HTTPURLResponse {
    func modifyingHeaderFields(_ map: (inout [String: String]) -> Void) -> HTTPURLResponse {
        var modifiedFields = allHeaderFields as! [String: String]
        map(&modifiedFields)
        let modifiedResponse = HTTPURLResponse(
            url: url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: modifiedFields
        )
        return modifiedResponse!
    }
}
