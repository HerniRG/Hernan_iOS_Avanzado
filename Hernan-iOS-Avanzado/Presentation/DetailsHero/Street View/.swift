//
//  StreetViewViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 23/10/24.
//

import UIKit
import MapKit

class StreetViewViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D?
    private var sceneView: MKARoundScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    private func setupScene() {
        // Inicializa el MKARoundScene
        guard let coordinate = coordinate else { return }
        sceneView = MKARoundScene(coordinate: coordinate, frame: self.view.bounds)
        self.view.addSubview(sceneView)
        
        // Asegúrate de que ocupa toda la vista
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
