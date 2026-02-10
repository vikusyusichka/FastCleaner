import Foundation

final class HomeViewModel {

    enum AccessUIState: Equatable {
        case unlocked
        case lockedNeedsRequest
        case lockedDenied
        case lockedRestricted
        case lockedUnknown
    }

    private let permissionService: PhotoPermissionServicing

    private(set) var state: AccessUIState = .lockedUnknown {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((AccessUIState) -> Void)?

    init(permissionService: PhotoPermissionServicing) {
        self.permissionService = permissionService
    }

    func refresh() {
        let status = permissionService.currentStatus()
        state = map(status)
    }

    private func map(_ status: PhotoPermissionStatus) -> AccessUIState {
        if status.isGranted { return .unlocked }

        switch status {
        case .notDetermined:
            return .lockedNeedsRequest
        case .denied:
            return .lockedDenied
        case .restricted:
            return .lockedRestricted
        case .unknown:
            return .lockedUnknown
        case .grantedFull, .grantedLimited:
            return .unlocked
        }
    }
}
