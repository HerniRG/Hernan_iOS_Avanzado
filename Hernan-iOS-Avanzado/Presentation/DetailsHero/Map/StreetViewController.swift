//
//  StreetViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 24/10/24.
//

import UIKit
import MapKit

class StreetViewController: UIViewController, MKLookAroundViewControllerDelegate {

    var scene: MKLookAroundScene? // Recibir la escena directamente

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAroundView()
    }

    private func setupLookAroundView() {
        guard let scene = scene else {
            showErrorMessage("Lo sentimos, esta localización no está cubierta por el servicio Look Around de Apple Maps.", shouldDismiss: true)
            return
        }

        let lookAroundViewController = MKLookAroundViewController(scene: scene)
        lookAroundViewController.delegate = self
        lookAroundViewController.view.frame = self.view.bounds
        lookAroundViewController.badgePosition = .bottomTrailing // Opcional: colocar la insignia donde prefieras

        // Añadir como Child View Controller
        addChild(lookAroundViewController)
        view.addSubview(lookAroundViewController.view)
    }

    func lookAroundViewControllerWillDismissFullScreen(_ viewController: MKLookAroundViewController) {
        dismiss(animated: true, completion: nil)
    }
}
