import UIKit

final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    private let titleLabel = UILabel()
    private let stateLabel = UILabel()
    private let openAccessButton = UIButton(type: .system)

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "FastCleaner"
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.refresh()
    }

    private func setupUI() {
        stateLabel.textAlignment = .center
        stateLabel.numberOfLines = 0
        stateLabel.translatesAutoresizingMaskIntoConstraints = false

        openAccessButton.setTitle("Enable Photo Access", for: .normal)
        openAccessButton.translatesAutoresizingMaskIntoConstraints = false
        openAccessButton.addTarget(self, action: #selector(openPhotoAccess), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(stateLabel)
        view.addSubview(openAccessButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            openAccessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openAccessButton.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 16)
        ])
    }

    private func render(_ state: HomeViewModel.AccessUIState) {
        switch state {
        case .unlocked:
            stateLabel.text = "Access granted. You can scan and clean."
            openAccessButton.isHidden = true

        case .lockedNeedsRequest:
            stateLabel.text = "Photo access is needed to scan duplicates and compress videos."
            openAccessButton.isHidden = false

        case .lockedDenied:
            stateLabel.text = "Access denied. Open settings to allow photo access."
            openAccessButton.isHidden = false

        case .lockedRestricted:
            stateLabel.text = "Access restricted by system settings."
            openAccessButton.isHidden = false

        case .lockedUnknown:
            stateLabel.text = "Unknown permission state."
            openAccessButton.isHidden = false
        }
    }

    @objc private func openPhotoAccess() {
        let permissionService = PhotoPermissionService()
        let vm = PhotoAccessViewModel(permissionService: permissionService)
        let vc = PhotoAccessViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
