import Photos

enum PhotoPermissionStatus: Equatable {
    case notDetermined
    case grantedFull
    case grantedLimited
    case denied
    case restricted
    case unknown

    init(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .grantedFull
        case .limited:
            self = .grantedLimited
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        @unknown default:
            self = .unknown
        }
    }

    var isGranted: Bool {
        switch self {
        case .grantedFull, .grantedLimited:
            return true
        default:
            return false
        }
    }
}

