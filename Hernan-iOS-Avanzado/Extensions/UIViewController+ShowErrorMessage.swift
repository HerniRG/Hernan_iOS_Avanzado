//
//  UIViewController+ShowErrorMessage.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 24/10/24.
//

import UIKit

extension UIViewController {
    func showErrorMessage(_ message: String, shouldDismiss: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
            if shouldDismiss {
                self.dismiss(animated: true, completion: nil)
            }
            completion?() // Se ejecuta solo cuando el usuario presiona "Aceptar"
        }
        okAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
