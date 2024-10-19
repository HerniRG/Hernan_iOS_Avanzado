//  MapViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 18/10/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    var mapView: MKMapView!
    var annotations: [HeroAnnotation] = []
    private var currentAnnotationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupNextAnnotationButton()
        setupMapTypeButton()  // Añadir el botón de tipo de mapa
        addAnnotationsToMap()
        moveToNextAnnotation()
    }
    
    // MARK: - Configurar el MapView
    private func setupMapView() {
        title = "Localizaciones"
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    // MARK: - Agregar anotaciones y centrar el mapa
    private func addAnnotationsToMap() {
        mapView.addAnnotations(annotations)
        if let firstAnnotation = annotations.first {
            mapView.setRegion(MKCoordinateRegion(center: firstAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
        }
    }
    
    // MARK: - Botón para cambiar el tipo de mapa
    private func setupMapTypeButton() {
        let mapTypeButton = UIButton(type: .system)
        mapTypeButton.setTitle("Tipo de mapa", for: .normal)
        mapTypeButton.backgroundColor = .systemCyan
        mapTypeButton.setTitleColor(.label, for: .normal)
        mapTypeButton.layer.cornerRadius = 10
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mapTypeButton.addTarget(self, action: #selector(toggleMapType), for: .touchUpInside)
        view.addSubview(mapTypeButton)
        
        // Constraints para el botón en la parte superior
        NSLayoutConstraint.activate([
            mapTypeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mapTypeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mapTypeButton.widthAnchor.constraint(equalToConstant: 120),
            mapTypeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Cambiar el tipo de mapa
    @objc private func toggleMapType() {
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
    
    // MARK: - Botón para moverse entre anotaciones
    private func setupNextAnnotationButton() {
        guard annotations.count > 1 else {
            title = "Localización"
            return
        }
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Siguiente", for: .normal)
        nextButton.backgroundColor = .systemOrange
        nextButton.setTitleColor(.label, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(moveToNextAnnotation), for: .touchUpInside)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 150),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Mover a la siguiente anotación
    @objc private func moveToNextAnnotation() {
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
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) {
            return annotationView
        }
        let annotationView = HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
        return annotationView
    }
}
