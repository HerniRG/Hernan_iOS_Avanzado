//
//  MapViewViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var annotations: [HeroAnnotation] = []
    private var currentAnnotationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addAnnotationsToMap()
    }
    
    // MARK: - Configurar el MapView
    private func setupMapView() {
        title = "Localizaciones"
        mapView.delegate = self
    }
    
    // MARK: - Agregar anotaciones y centrar el mapa
    private func addAnnotationsToMap() {
        mapView.addAnnotations(annotations)
        if let firstAnnotation = annotations.first {
            mapView.setRegion(MKCoordinateRegion(center: firstAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
        }
        // Ocultar el botón de "Siguiente" si solo hay una anotación
        if annotations.count <= 1 {
            title = "Localización"
            // Asumiendo que el botón de siguiente tiene un IBOutlet llamado "nextButton"
            nextButton.isHidden = true
        } else {
            nextButton.isHidden = false
        }
    }
    
    @IBAction func didToggleMapTapped(_ sender: Any) {
        switch mapView.mapType {
        case .standard:
            mapView.mapType = .satellite
        case .satellite:
            mapView.mapType = .hybrid
        case .hybrid:
            mapView.mapType = .standard
        default:
            mapView.mapType = .standard
        }
    }

    @IBAction func didMoveToNextAnnotationTapped(_ sender: Any) {
        guard !annotations.isEmpty else { return }
        currentAnnotationIndex = (currentAnnotationIndex + 1) % annotations.count
        let nextAnnotation = annotations[currentAnnotationIndex]
        mapView.setRegion(MKCoordinateRegion(center: nextAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
        mapView.selectAnnotation(nextAnnotation, animated: true)
    }
    
    // MARK: - Configurar las anotaciones
    func configure(with annotations: [HeroAnnotation]) {
        self.annotations = annotations
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? HeroAnnotation else { return nil }
        
        // Intenta reutilizar la vista de anotación
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) as? HeroAnnotationView {
            annotationView.annotation = annotation
            return annotationView
        }
        
        // Crear una nueva vista de anotación si no se puede reutilizar
        let annotationView = HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
        return annotationView
    }
}
