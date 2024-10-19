//
//  MapViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 18/10/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var mapView: MKMapView!
    var annotations: [HeroAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addAnnotationsToMap()
    }
    
    // Configurar el MapView
    private func setupMapView() {
        title = "Localizaciones"
        mapView = MKMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
    }
    
    // Agregar las anotaciones recibidas
    private func addAnnotationsToMap() {
        mapView.addAnnotations(annotations)
        
        if let firstAnnotation = annotations.first {
            let region = MKCoordinateRegion(center: firstAnnotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Función para recibir las anotaciones
    func configure(with annotations: [HeroAnnotation]) {
        self.annotations = annotations
    }
}
