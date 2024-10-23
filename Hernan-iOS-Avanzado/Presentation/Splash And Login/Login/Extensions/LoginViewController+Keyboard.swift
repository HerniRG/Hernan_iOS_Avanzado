//
//  LoginViewController+Keyboard.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 23/10/24.
//

import UIKit

extension LoginViewController {
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        adjustContainerForKeyboard(notification: notification, shouldMoveUp: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        adjustContainerForKeyboard(notification: notification, shouldMoveUp: false)
    }

    func adjustContainerForKeyboard(notification: NSNotification, shouldMoveUp: Bool) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = shouldMoveUp ? -(keyboardFrame.height / 2) : 0
            animateConstraintChange(to: keyboardHeight)
        }
    }
}
