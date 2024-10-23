//
//  LoginViewController+Animations.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 23/10/24.
//

import UIKit

extension LoginViewController {

    func animateConstraintChange(to constant: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.loginContainerVerticalConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    func showLoginContainer(animated: Bool) {
        loginContainerView.alpha = 0
        loginContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        loginContainerView.isHidden = false

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.loginContainerView.alpha = 1
                self.loginContainerView.transform = .identity
            }) { _ in
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

    func hideLoginContainer(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.loginContainerView.alpha = 0
                self.loginContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.loginContainerView.isHidden = true
            }
        } else {
            loginContainerView.isHidden = true
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
