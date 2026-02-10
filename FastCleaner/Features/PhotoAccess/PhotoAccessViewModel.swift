import Foundation

final class PhotoAccessViewModel {

    enum State: Equatable {
        case requesting
        case granted
        case denied
        case restricted
        case unknown
    }

    private let permissionService: PhotoPermissionServicing

    private(set) var state: State = .requesting {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((State) -> Void)?

    init(permissionService: PhotoPermissionServicing) {
        self.permissionService = permissionService
    }

    func start() {
        let status = permissionService.currentStatus()
        apply(status: status)
        if status == .notDetermined {
            request()
        }
    }

    func request() {
        state = .requesting
        permissionService.requestReadWrite { [weak self] status in
            self?.apply(status: status)
        }
    }

    private func apply(status: PhotoPermissionStatus) {
        if status.isGranted {
            state = .granted
            return
        }

        switch status {
        case .notDetermined:
            state = .requesting
        case .denied:
            state = .denied
        case .restricted:
            state = .restricted
        case .unknown:
            state = .unknown
        case .grantedFull, .grantedLimited:
            state = .granted
        }
    }
}

