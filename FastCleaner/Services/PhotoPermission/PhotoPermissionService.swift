import Photos

protocol PhotoPermissionServicing {
    func currentStatus() -> PhotoPermissionStatus
    func requestReadWrite(completion: @escaping (PhotoPermissionStatus) -> Void)
}

final class PhotoPermissionService: PhotoPermissionServicing {

    func currentStatus() -> PhotoPermissionStatus {
        PhotoPermissionStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestReadWrite(completion: @escaping (PhotoPermissionStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(PhotoPermissionStatus(status))
        }
    }
}

