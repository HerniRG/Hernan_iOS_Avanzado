//
//  LoginViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var loginContainerVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - ViewModel
    let viewModel = LoginViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setBinding()
        observeKeyboardNotifications()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        setupLoginContainerView()
        activityIndicator.isHidden = true
        
        // Configuración de los UITextFields
        usernameTextField.backgroundColor = .secondarySystemBackground
        usernameTextField.textColor = .label
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.textColor = .label
    }
    
    private func setupLoginContainerView() {
        loginContainerView.layer.cornerRadius = 10
        loginContainerView.layer.borderWidth = 0.5
        loginContainerView.layer.borderColor = UIColor.systemGray.cgColor
        loginContainerView.backgroundColor = .secondarySystemBackground
    }
    
    // MARK: - Keyboard Handling
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        adjustContainerForKeyboard(notification: notification, shouldMoveUp: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        adjustContainerForKeyboard(notification: notification, shouldMoveUp: false)
    }
    
    private func adjustContainerForKeyboard(notification: NSNotification, shouldMoveUp: Bool) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = shouldMoveUp ? -(keyboardFrame.height / 2) : 0
            animateConstraintChange(to: keyboardHeight)
        }
    }
    
    private func animateConstraintChange(to constant: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.loginContainerVerticalConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Binding ViewModel
    private func setBinding() {
        viewModel.statusLogin.bind { [weak self] status in
            self?.handleLoginStatus(status)
        }
    }
    
    private func handleLoginStatus(_ status: StatusLogin) {
        switch status {
        case .success:
            hideActivityIndicator()
            self.navigateToHeroesViewController()
            
        case .error(let msg):
            hideLoginContainer()
            showAlert(title: "Error", message: msg) {
                self.hideActivityIndicator()
                self.viewModel.statusLogin.value = .none
            }
            
        case .loading:
            showActivityIndicator()
            hideLoginContainer(animated: true)
            
        case .none:
            showLoginContainer(animated: true)
        }
    }
    
    // MARK: - Navigate to HeroesViewController
    private func navigateToHeroesViewController() {
        let heroesViewController = HeroesViewController()
        self.navigationController?.pushViewController(heroesViewController, animated: true)
    }
    
    // MARK: - UI Handling
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showLoginContainer(animated: Bool) {
        loginContainerView.isHidden = false
        if animated {
            animateViewAlpha(loginContainerView, to: 1)
        }
    }
    
    private func hideLoginContainer(animated: Bool = false) {
        if animated {
            animateViewAlpha(loginContainerView, to: 0) {
                self.loginContainerView.isHidden = true
            }
        } else {
            loginContainerView.isHidden = true
        }
    }
    
    private func animateViewAlpha(_ view: UIView, to alpha: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = alpha
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        viewModel.login(username: username, password: password)
    }
    
    // MARK: - Alerts
    private func showAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        self.present(alert, animated: true, completion: nil)
    }
}
