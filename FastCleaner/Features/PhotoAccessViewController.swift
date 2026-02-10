import UIKit
import Photos

final class PhotoAccessViewController: UIViewController {

    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePhotoPermissionFlow()
    }

    private func handlePhotoPermissionFlow() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .notDetermined:
            requestPhotoAccess()

        case .authorized, .limited:
            showGalleryUI()

        case .denied, .restricted:
            showDeniedUI()

        @unknown default:
            showDeniedUI()
        }
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
            DispatchQueue.main.async {
                self?.handlePhotoPermissionFlow() // або self?.handle(status: newStatus)
            }
        }
    }

    // MARK: - UI

    private func setupLayout() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func clearContent() {
        contentStack.arrangedSubviews.forEach { v in
            contentStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
    }

    private func showGalleryUI() {
        clearContent()

        let label = UILabel()
        label.text = "Success"
        label.textAlignment = .center

        contentStack.addArrangedSubview(label)
    }

    private func showDeniedUI() {
        clearContent()

        let label = UILabel()
        label.text = "Open Settings to continue"
        label.numberOfLines = 0
        label.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Open Settings", for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        contentStack.addArrangedSubview(label)
        contentStack.addArrangedSubview(button)
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
