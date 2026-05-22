//
//  LoginViewController.swift
//  CICD_Demo
//

import UIKit

final class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CICD Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        usernameField.placeholder = "Username (demo)"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.accessibilityIdentifier = "login_username"

        passwordField.placeholder = "Password (pass123)"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.accessibilityIdentifier = "login_password"

        loginButton.setTitle("Login", for: .normal)
        loginButton.accessibilityIdentifier = "login_button"
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.accessibilityIdentifier = "login_status"

        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, loginButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    @objc private func didTapLogin() {
        loginButton.isEnabled = false
        statusLabel.text = "Loading..."

        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""

        Task { @MainActor in
            await viewModel.login(username: username, password: password)
            loginButton.isEnabled = true

            if let name = viewModel.displayName {
                statusLabel.text = "Welcome, \(name)"
            } else {
                statusLabel.text = viewModel.errorMessage
            }
        }
    }
}
