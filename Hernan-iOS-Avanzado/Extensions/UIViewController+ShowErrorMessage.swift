//
//  UIViewController+ShowErrorMessage.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 24/10/24.
//

import UIKit

extension UIViewController {
    func showErrorMessage(_ message: String, shouldDismiss: Bool = false) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
            if shouldDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        })
        present(alert, animated: true, completion: nil)
    }
}
