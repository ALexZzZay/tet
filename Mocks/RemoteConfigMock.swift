import Foundation
import CommonServicesInterface

enum RemoteConfigMock {
    private class BundleDetectionClass {}

    static func jsonFile(_ fileName: String) -> String {
        let bundle = Bundle(for: BundleDetectionClass.self)
        let url = bundle.url(forResource: fileName, withExtension: nil)
        let result = try? String(contentsOf: url!)
        return result!
    }
}

extension SwiftTestsHost {
    func overrideRemoteConfig(key: RemoteConfigKey, value: String) {
        overrideRemoteConfig(key: key.key, value: value)
    }
}
