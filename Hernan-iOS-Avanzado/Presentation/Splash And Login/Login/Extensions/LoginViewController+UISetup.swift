//
//  LoginViewController+UISetup.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 23/10/24.
//

import UIKit

extension LoginViewController {

    func configureUI() {
        setupLoginContainerView()
        setupTextFields()
        activityIndicator.isHidden = true
    }
    
    private func setupLoginContainerView() {
        loginContainerView.layer.cornerRadius = 10
        loginContainerView.layer.borderWidth = 0.5
        loginContainerView.layer.borderColor = UIColor.systemGray.cgColor
        loginContainerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
    }

    private func setupTextFields() {
        usernameTextField.backgroundColor = .secondarySystemBackground
        usernameTextField.textColor = .label
        
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.textColor = .label
        setupPasswordToggle()
    }
    
    private func setupPasswordToggle() {
        let passwordToggleButton = UIButton(type: .custom)
        passwordToggleButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        passwordToggleButton.tintColor = .label
        passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        passwordToggleButton.center = paddingView.center
        paddingView.addSubview(passwordToggleButton)
        
        passwordTextField.rightView = paddingView
        passwordTextField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }
}
