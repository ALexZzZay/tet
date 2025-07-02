import Foundation

// Bridge to talk with app
func appHost() -> SwiftTestsHost {
    unsafeBitCast(GREYHostApplicationDistantObject.sharedInstance, to: SwiftTestsHost.self)
}
