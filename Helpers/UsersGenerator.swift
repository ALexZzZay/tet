import Foundation

enum UsersGenerator {

    static let defaultName = "T53O0PWRQT"

    static func getLoginCodeForNewUser(isUserOnboarded: Bool, hasFinishedUnboxing: Bool, email: String) -> String {
        let code = UnsafeBox<String>("")

        Task { [code] in
            do {
                code.obj = try await getLoginCodeForNewUserAsync(
                    isUserOnboarded: isUserOnboarded,
                    hasFinishedUnboxing: hasFinishedUnboxing,
                    email: email
                )
            } catch {
                GREYAssert(false, "Can't create login code: \(error)")
            }
        }

        let didCreateLoginCode = GREYCondition(name: "waiting for preparing login code") {
            !code.obj.isEmpty
        }.wait(withTimeout: 15, pollInterval: 1)
        GREYAssertTrue(didCreateLoginCode, "Can't create login code")
        return code.obj
    }

    private static func getLoginCodeForNewUserAsync(isUserOnboarded: Bool, hasFinishedUnboxing: Bool, email: String) async throws -> String {
        let jwt = try await generateJWT()
        try await generateUser(jwt: jwt, email: email, isOnboardedUser: isUserOnboarded, hasFinishedUnboxing: hasFinishedUnboxing)
        try await userCheck(jwt: jwt, email: email)
        let loginCode = try await generateLoginCode(jwt: jwt, email: email)
        return loginCode
    }
}

enum EmailsGenerator {
    static func randomEmail() -> String {
        let rnd = (1..<2_000_000_000).randomElement()!
        return "random_\(rnd)@fstr.app"
    }
}

// MARK: - Private

private class UnsafeBox<T>: @unchecked Sendable {
    var obj: T
    init(_ obj: T) {
        self.obj = obj
    }
}

private func generateJWT() async throws -> JWT {
    let resp: WrappedResponse<JWT> = try await request(
        .get,
        url: URL(string: "https://rest.dev.fstr.app/v1/user/token")!,
        jwt: nil
    )
    return resp.data
}

private func generateUser(jwt: JWT, email: String, isOnboardedUser: Bool, hasFinishedUnboxing: Bool) async throws {
    var params: [String: Any] = [
        "name": UsersGenerator.defaultName,
        "email": email
    ]

    if isOnboardedUser {
        let onboardedParams: [String: Any] = [
            "sex": "female",
            "weight": 70,
            "goalStartWeight": 70,
            "targetWeight": 70,
            "height": 160,
            "birthDate": "2002-03-01",
            "secondsFromGMT": 0
        ]
        params.merge(onboardedParams, uniquingKeysWith: { _, new in new })
    }
    if hasFinishedUnboxing {
        params.merge(["data": ["did_finish_unboxing_v5": true]], uniquingKeysWith: { _, new in new })
    }

    let _: Empty = try await request(
        .put,
        url: URL(string: "https://rest.dev.fstr.app/v1/user")!,
        params: params,
        jwt: jwt
    )
}

private func userCheck(jwt: JWT, email: String) async throws {
    let _: WrappedResponse<String> = try await request(
        .post,
        url: URL(string: "https://rest.dev.fstr.app/v1/user/check")!,
        params: ["email": email],
        jwt: jwt
    )
}

private func generateLoginCode(jwt: JWT, email: String) async throws -> String {
    let resp: WrappedResponse<String> = try await request(
        .post,
        url: URL(string: "https://rest.dev.fstr.app/v1/user/login/code/generate")!,
        params: ["email": email],
        jwt: jwt
    )
    return resp.data
}

// MARK: - Models

private struct WrappedResponse<T: Decodable>: Decodable {
    let data: T
}

struct Empty: Decodable {}

private struct JWT: Decodable {
    let token: String
    let refreshToken: String
}

// MARK: - Helpers

private func request<ResponseModel: Decodable>(
    _ method: HTTPMethod,
    url: URL,
    params: [String: Any] = [:],
    jwt: JWT?
) async throws -> ResponseModel {

    var req = URLRequest(url: url)
    req.setValue("ios-7.5", forHTTPHeaderField: "Simple-App-Version")
    req.httpMethod = method.rawValue

    if !params.isEmpty {
        req.httpBody = try JSONSerialization.data(withJSONObject: params)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    if let jwt = jwt {
        req.setValue("Bearer \(jwt.token)", forHTTPHeaderField: "Authorization")
    }

    let (data, resp) = try await URLSession.shared.data(for: req)
    let statusCode = (resp as! HTTPURLResponse).statusCode
    guard (200..<300).contains(statusCode) else {
        throw Errors.badStatusCode(statusCode)
    }

    return try JSONDecoder().decode(ResponseModel.self, from: data)
}

private enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

private enum Errors: Error {
    case badStatusCode(Int)
}
