import Foundation
import Photos

enum PhotosAppImage: String {
    case burger = "burger.jpg"
}

struct PhotosAppImageInfo {
    let index: Int
    let identifier: String
}

protocol PhotosAppTest: XCTestCase {

    func addImages(_ images: [PhotosAppImage])
    func removeImages()

    var images: [PhotosAppImage: PhotosAppImageInfo] { get set }
}

extension PhotosAppTest {

    func addImages(_ images: [PhotosAppImage]) {
        askPermissions()

        let uiImages = images.map { BundleHelper.loadImage(name: $0.rawValue) }
        var isFinished = false

        appHost().addImagesToPhotoApp(uiImages) {
            for (index, image) in images.enumerated() {
                self.images[image] = .init(index: index, identifier: $0[index])
            }

            isFinished = true
        }

        tapOnAlert()

        _ = GREYCondition(name: "waiting for performing changes in photos") {
            isFinished
        }.wait(withTimeout: 10, pollInterval: 1)
    }

    func removeImages() {
        askPermissions()

        let identifiers = self.images.map { $1.identifier }
        var isFinished = false

        appHost().removeImagesFromPhotoApp(identifiers: identifiers) {
            isFinished = true
        }

        tapOnAlert()

        _ = GREYCondition(name: "waiting for performing changes in photos") {
            isFinished
        }.wait(withTimeout: 10, pollInterval: 1)
    }

    private func askPermissions() {
        if appHost().shouldRequestPhotoAppAuthStatus() {
            appHost().requestPhotoAppAuthStatus()
            tapOnAlert()
        }
    }

    private func tapOnAlert() {
        let systemAlertShown = self.grey_wait(forAlertVisibility: true, withTimeout: 5)
        if systemAlertShown {
            self.grey_acceptSystemDialogWithError(nil)
        }
    }
}
