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
        
        // Configuración de passwordTextField
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.textColor = .label
        setupPasswordToggle()
    }
    
    private func setupLoginContainerView() {
        loginContainerView.layer.cornerRadius = 10
        loginContainerView.layer.borderWidth = 0.5
        loginContainerView.layer.borderColor = UIColor.systemGray.cgColor
        loginContainerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
    }
    
    private func setupPasswordToggle() {
        // Crear botón
        let passwordToggleButton = UIButton(type: .custom)
        passwordToggleButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        passwordToggleButton.tintColor = .label
        passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        // Asignar función al botón
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Crear un contenedor para el botón con un padding a la derecha
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24)) // Espacio adicional a la derecha
        passwordToggleButton.center = paddingView.center
        paddingView.addSubview(passwordToggleButton)
        
        // Configurar el contenedor como el rightView del passwordTextField
        passwordTextField.rightView = paddingView
        passwordTextField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle() // Cambiar el estado del botón
        
        // Alternar el modo de seguridad del campo de texto
        passwordTextField.isSecureTextEntry.toggle()
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
            guard let self = self else { return } // Aseguramos que self no sea nil
            
            switch status {
            case .success:
                self.hideActivityIndicator()
                self.navigateToHeroesViewController()
                
            case .error(let msg):
                self.hideLoginContainer()
                self.showAlert(title: "Error", message: msg) {
                    self.hideActivityIndicator()
                    self.viewModel.statusLogin.value = .none
                }
                
            case .loading:
                self.showActivityIndicator()
                self.hideLoginContainer(animated: true)
                
            case .none:
                self.showLoginContainer(animated: true)
            }
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
        loginContainerView.alpha = 0
        loginContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Comienza escalado

        loginContainerView.isHidden = false

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.loginContainerView.alpha = 1 // Desvanecimiento a 1
                self.loginContainerView.transform = .identity // Vuelve a su tamaño original
            }) { _ in
                // Agregamos un efecto de "rebote"
                UIView.animate(withDuration: 0.1, animations: {
                    self.loginContainerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.loginContainerView.transform = .identity
                    }
                }
            }
        } else {
            loginContainerView.alpha = 1
            loginContainerView.transform = .identity
        }
    }

    private func hideLoginContainer(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.loginContainerView.alpha = 0 // Desvanecimiento a 0
                self.loginContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Se escala hacia abajo
            }) { _ in
                self.loginContainerView.isHidden = true
            }
        } else {
            loginContainerView.isHidden = true
        }
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
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            completion()
        }
        okAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
