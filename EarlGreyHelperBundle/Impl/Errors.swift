import Foundation

private let customGreyErrorDomain = "customGreyErrorDomain"

func makeGreyError(reason: String) -> NSError {
    let errorInfo = [NSLocalizedDescriptionKey: reason]
    return NSError(domain: customGreyErrorDomain, code: 0, userInfo: errorInfo)
}
