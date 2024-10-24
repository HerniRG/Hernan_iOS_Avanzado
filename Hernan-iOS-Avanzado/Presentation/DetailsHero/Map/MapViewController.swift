//
//  MapViewViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager: CLLocationManager = CLLocationManager()
    
    // MARK: - Properties
    private var viewModel: MapViewModel
    
    init(viewModel: MapViewModel = MapViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: MapViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupBindings()
        
        // Configurar delegado y verificar autorización de ubicación
        locationManager.delegate = self
        checkAuthLocation()
    }
    
    // MARK: - Configurar el MapView
    private func setupMapView() {
        updateTitleForAnnotations()
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.isZoomEnabled = true
    }
    
    // MARK: - Check Auth Location
    private func checkAuthLocation() {
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            mapView.showsUserLocation = false
            mapView.showsUserTrackingButton = false
        case .authorizedAlways, .authorizedWhenInUse:
            enableUserLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - Habilitar la ubicación del usuario
    private func enableUserLocation() {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Habilitar el botón de localización al concederse los permisos
            enableUserLocation()
        case .denied, .restricted:
            mapView.showsUserLocation = false
            mapView.showsUserTrackingButton = false
        default:
            break
        }
    }
    
    // MARK: - Configurar los bindings
    private func setupBindings() {
        viewModel.status.bind { [weak self] status in
            switch status {
            case .loading:
                break
            case .success:
                self?.updateMap()
                if self?.viewModel.isNextButtonChangeText == true {
                    self?.nextButton.setTitle("Localización", for: .normal)
                } else {
                    self?.nextButton.setTitle("Localizaciones", for: .normal)
                }
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
        configureNavigationBar(title: "Localizaciones", backgroundColor: .systemBackground)
        title = viewModel.annotationCount == 1 ? "Localización" : "Localizaciones"
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? HeroAnnotation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) as? HeroAnnotationView ?? HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
        
        // Realizar la solicitud de la escena Look Around antes de configurar el callout
        let coordinate = annotation.coordinate
        let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        
        Task {
            do {
                // Si hay escena disponible, configuramos el botón de Street View
                if (try await sceneRequest.scene) != nil {
                    annotationView.configureButtonAction(target: self, action: #selector(self.streetViewButtonTapped(_:)))
                } else {
                    // Si no hay escena, no mostramos el botón
                    annotationView.rightCalloutAccessoryView = nil

                }
            } catch {
                print("Error al verificar la escena de Look Around: \(error.localizedDescription)")
            }
        }
        
        return annotationView
    }
    
    @objc private func streetViewButtonTapped(_ sender: UIButton) {
        
        // Buscar la supervista del botón hasta encontrar la MKAnnotationView
        var view: UIView? = sender
        while view != nil && !(view is MKAnnotationView) {
            view = view?.superview
        }
        
        // Verificar si encontramos la vista de anotación
        guard let annotationView = view as? HeroAnnotationView,
              let annotation = annotationView.annotation as? HeroAnnotation else {
            print("No se pudo obtener la anotación.")
            return
        }
        
        // Obtener la coordenada desde el ViewModel
        if let coordinate = viewModel.getCoordinate(for: annotation) {
            // Realizar la solicitud de la escena antes de navegar
            let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
            
            Task {
                do {
                    if let scene = try await sceneRequest.scene {
                        // Solo si hay escena disponible, presentamos el controlador y pasamos la escena
                        let streetViewVC = StreetViewController()
                        streetViewVC.scene = scene // Pasar la escena obtenida
                        streetViewVC.modalPresentationStyle = .fullScreen
                        
                        self.present(streetViewVC, animated: true)
                    } else {
                        // Si no hay escena, mostrar mensaje de error y no navegar
                        self.showErrorMessage("Lo sentimos, esta localización no está cubierta por el servicio Look Around de Apple Maps.")
                    }
                } catch {
                    // Manejar el error de la solicitud de la escena
                    self.showErrorMessage("Error al cargar la escena: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
