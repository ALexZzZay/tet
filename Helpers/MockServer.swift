import Foundation
@preconcurrency import Ambassador
@preconcurrency import Embassy
import ConcurrencyExtras

@MainActor
final class MockServer {

    static let shared = MockServer()

    private static let maxAttemptsCount = 10
    private static let startPort: Int = (9080...10080).randomElement()!
    private static let endPort = startPort + 1000

    var port = startPort

    private var router: Router!
    private var server: DefaultHTTPServer!

    private nonisolated
    let eventLoop = LockIsolated<EventLoop?>(nil)

    private var eventLoopThreadCondition: NSCondition!
    private var eventLoopThread: Thread!

    var mocks = [ServerMockData]() {
        didSet {
            setMocks()
        }
    }

    private var started = false
    private var startAttemptsCount = 0

    private lazy var currentBundle: Bundle = {
        Bundle(for: Self.self)
    }()

    private enum CheckServerError: Error {
        case notResponding
    }

    deinit {
        // uncomment if deinit will be main actor
        // stop if not necessary because deinit is never called for shared instance
        // stop()
    }

    func start() {
        guard !started else {
            return
        }
        startAttemptsCount = 0
        tryStart(port)
    }

    private func setMocks() {
        if router == nil {
            router = Router()
        }

        for mock in mocks {
            guard mock.isValid() else {
                continue
            }
            guard var components = URLComponents(string: mock.urlTemplate) else {
                continue
            }
            let host = extractHost(components: components)
            components.scheme = nil
            components.host = nil
            guard let urlTemplate = components.string else {
                continue
            }

            let regexUrlTemplate = urlTemplate.replacing(NonIsolated.makeParamRegex(), with: "/([^/]+)")
                + "$"
            router[regexUrlTemplate] = SWGIWebApp(handler: NonIsolated.makeRequestHandler(host: host, urlTemplate: urlTemplate, mock: mock, eventLoop: eventLoop))
        }
    }

    private func tryStart(_ port: Int) {
        guard let router = router else {
            return
        }
        do {
            try eventLoop.setValue(SelectorEventLoop(selector: try KqueueSelector()))
            server = DefaultHTTPServer(eventLoop: eventLoop.value!, port: port, app: router.app)

            try server.start()

            eventLoopThreadCondition = NSCondition()
            eventLoopThread = Thread(block: NonIsolated.makeEventLoopThreadHandler(eventLoop: eventLoop, eventLoopThreadCondition: eventLoopThreadCondition!))
            eventLoopThread.start()

            self.port = port
            guard NonIsolated.checkServer(port: port) else {
                stop()
                throw CheckServerError.notResponding
            }

            logger.info("[MockServer] started on port \(port)")

            started = true
        } catch {
            guard startAttemptsCount < Self.maxAttemptsCount, port < Self.endPort else {
                XCTFail("Start mock server error: \(error)")
                return
            }
            tryStart(port + 1)
        }
        startAttemptsCount += 1
    }

    func stop() {
        mocks = []

        server?.stopAndWait()
        eventLoopThreadCondition?.lock()
        eventLoop.value?.stop()
        eventLoopThreadCondition?.wait(until: .init().bySetting(seconds: 3))
        eventLoopThreadCondition?.unlock()
        eventLoopThread?.cancel()

        router = nil
        server = nil
        eventLoop.setValue(nil)
        eventLoopThreadCondition = nil
        eventLoopThread = nil

        started = false
    }

    private func extractHost(components: URLComponents) -> String {
        var hostComponents = URLComponents()
        hostComponents.scheme = components.scheme
        hostComponents.host = components.host
        return hostComponents.string!
    }
}

private class NonIsolated {
    static func makeParamRegex() -> Regex<(Substring, Substring)> {
        /\/(:[^\/]+)/
    }

    static func extractParams(urlTemplate: String, environ: [String: Any]) -> [String: String] {
        let matches: [Substring] = urlTemplate.matches(of: makeParamRegex()).map { $0.output.1 }
        guard !matches.isEmpty else {
            return [:]
        }
        guard let captures = environ["ambassador.router_captures"] as? [String], captures.count == matches.count else {
            return [:]
        }
        let params = zip(matches, captures)
        return params.reduce(into: [:]) { partialResult, param in
            partialResult[String(param.0)] = param.1
        }
    }

    static func makeEventLoopThreadHandler(eventLoop: LockIsolated<(any EventLoop)?>, eventLoopThreadCondition: NSCondition) -> @Sendable () -> Void {
        return {
            eventLoop.value?.runForever()
            eventLoopThreadCondition.lock()
            eventLoopThreadCondition.signal()
            eventLoopThreadCondition.unlock()
        }
    }

    static func makeRequestHandler(host: String, urlTemplate: String, mock: ServerMockData, eventLoop: LockIsolated<(any EventLoop)?>) -> SWSGI {
        return { environ, startResponse, sendBody in

            // this must be called on eventLoop
            nonisolated(unsafe) let startResponse = startResponse
            nonisolated(unsafe) let sendBody = sendBody

            URLRequest.fromEnviron(environ, host: host) { result in
                switch result {
                case .success(let urlRequest):
                    let params = NonIsolated.extractParams(urlTemplate: urlTemplate, environ: environ)
                    let request = ServerMockData.Handler.Request(
                        request: urlRequest,
                        params: params
                    )
                    mock.handler.run(request, { response in
                        eventLoop.value?.call {
                            startResponse(
                                StatusCode.other(code: response.response.statusCode).description,
                                response.response.allHeaderFields.map { ($0.key as! String, $0.value as! String) }
                            )
                            if let data = response.data, !data.isEmpty {
                                sendBody(data)
                            }
                            sendBody(Data())
                        }
                    })
                case .failure(let error):
                    XCTFail("\(error)")
                    startResponse(StatusCode.internalServerError.description, [])
                    sendBody(Data())
                }
            }
        }
    }

    static func checkServer(port: Int) -> Bool {
        guard let checkURL = URL(string: "http://localhost:\(port)/checkFor404") else {
            return false
        }

        let semaphore = DispatchSemaphore(value: 0)

        // there is no concurrent access to result because of semaphore
        nonisolated(unsafe) var result = false

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10

        let session = URLSession(configuration: sessionConfiguration)

        session.dataTask(with: checkURL) { _, response, _ in
            result = (response as? HTTPURLResponse)?.statusCode == 404
            semaphore.signal()
        }
        .resume()
        semaphore.wait()

        return result
    }
}

extension URLRequest {
    enum ParseError: Error {
        case error(String)
    }

    static func fromEnviron(_ environ: [String: Any], host: String, completion: @escaping (Result<URLRequest, ParseError>) -> Void) {
        let method = environ["REQUEST_METHOD"] as! String
        let path = environ["PATH_INFO"] as! String
        let queryString = environ["QUERY_STRING"] as? String
        let headers = environ["embassy.headers"] as! [(String, String)]

        var urlComponents = URLComponents()
        urlComponents.path = path
        urlComponents.query = queryString

        guard let hostUrl = URL(string: host), let url = URL(string: urlComponents.string ?? path, relativeTo: hostUrl) else {
            completion(.failure(.error("invalid url: \(host)->\(urlComponents)")))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.allHTTPHeaderFields = headers.reduce(into: [:], { partialResult, header in
            partialResult[header.0] = header.1
        })
        req.setValue(hostUrl.host(), forHTTPHeaderField: "Host")

        switch method {
        case "GET", "HEAD":
            completion(.success(req))
        default:
            var body: Data?
            let length = environ["HTTP_CONTENT_LENGTH"] as? String ?? "0"
            if length == "0" {
                completion(.success(req))
            } else {
                let input = environ["swsgi.input"] as! SWSGIInput
                input { data in
                    if data.isEmpty {
                        req.httpBody = body
                        completion(.success(req))
                    } else {
                        if body == nil {
                            body = Data()
                        }
                        body!.append(data)
                    }
                }
            }
        }
    }
}
