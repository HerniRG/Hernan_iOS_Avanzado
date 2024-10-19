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
    private var viewModel = MapViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupBindings()
    }
    
    // MARK: - Configurar el MapView
    private func setupMapView() {
        updateTitleForAnnotations()
        mapView.delegate = self
    }
    
    // MARK: - Configurar los bindings
    private func setupBindings() {
        viewModel.status.bind { [weak self] status in
            switch status {
            case .loading:
                break
            case .success:
                self?.updateMap()
                self?.nextButton.isHidden = self?.viewModel.isNextButtonHidden ?? true
            case .error(let msg):
                print("Error: \(msg)")
            }
        }
    }
    
    // Actualizar el mapa con las anotaciones
    private func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(viewModel.annotations)
        
        if let firstAnnotation = viewModel.firstAnnotation {
            mapView.setRegion(MKCoordinateRegion(center: firstAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
            mapView.selectAnnotation(firstAnnotation, animated: true)
        }
    }
    
    @IBAction func didMoveToNextAnnotationTapped(_ sender: Any) {
        if let nextAnnotation = viewModel.nextAnnotation() {
            mapView.setRegion(MKCoordinateRegion(center: nextAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000), animated: true)
            mapView.selectAnnotation(nextAnnotation, animated: true)
        }
    }
    
    @IBAction func didToggleMapTapped(_ sender: Any) {
        mapView.mapType = viewModel.toggleMapType()
    }
    
    // Configurar las anotaciones
    func configure(with annotations: [HeroAnnotation]) {
        viewModel.loadAnnotations(annotations)
    }
    
    // Actualizar el título basado en el número de anotaciones
    private func updateTitleForAnnotations() {
        title = viewModel.annotationCount == 1 ? "Localización" : "Localizaciones"
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
