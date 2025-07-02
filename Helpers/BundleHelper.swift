import Foundation

struct BundleHelper {

    private class BundleDetectionClass {}

    static func loadData(_ filePath: String, bundle: Bundle? = nil) -> Data {
        let realBundle = bundle ?? Bundle(for: BundleDetectionClass.self)
        let url = realBundle.url(forResource: filePath, withExtension: nil)
        let data = try? Data(contentsOf: url!)
        return data!
    }

    static func loadImage(name: String, bundle: Bundle? = nil) -> UIImage {
        let realBundle = bundle ?? Bundle(for: BundleDetectionClass.self)

        return UIImage(named: name, in: realBundle, compatibleWith: nil)!
    }
}
