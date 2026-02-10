import UIKit

final class PhotoAccessViewController: UIViewController {

    private let viewModel: PhotoAccessViewModel

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)

    init(viewModel: PhotoAccessViewModel) {
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
        title = "Photo Access"
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.start()
        render(viewModel.state)
    }

    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Allow access to Photos"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        primaryButton.setTitle("Continue", for: .normal)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        secondaryButton.setTitle("Open Settings", for: .normal)
        secondaryButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(primaryButton)
        stack.addArrangedSubview(secondaryButton)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func render(_ state: PhotoAccessViewModel.State) {
        switch state {
        case .requesting:
            messageLabel.text = "We need photo access to scan duplicates and optimize storage."
            primaryButton.isHidden = false
            secondaryButton.isHidden = true

        case .granted:
            dismiss(animated: true)

        case .denied:
            messageLabel.text = "Access denied. Please enable Photos access in Settings."
            primaryButton.isHidden = true
            secondaryButton.isHidden = false

        case .restricted:
            messageLabel.text = "Access restricted by system settings."
            primaryButton.isHidden = true
            secondaryButton.isHidden = false

        case .unknown:
            messageLabel.text = "Unknown permission state."
            primaryButton.isHidden = true
            secondaryButton.isHidden = false
        }
    }

    @objc private func primaryTapped() {
        viewModel.request()
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
