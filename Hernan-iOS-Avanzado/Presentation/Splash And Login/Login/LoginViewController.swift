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
    
    // MARK: - Binding ViewModel
    private func setBinding() {
        viewModel.statusLogin.bind { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .success:
                self.hideActivityIndicator()
                self.navigateToHeroesViewController()
                
            case .error(let msg):
                self.hideLoginContainer()
                self.showErrorMessage(msg) {
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
    
    // MARK: - Navigation
    private func navigateToHeroesViewController() {
        let heroesViewController = HeroesViewController()
        self.navigationController?.pushViewController(heroesViewController, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        viewModel.login(username: username, password: password)
    }
}
