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
        
        // Verificar autorización de ubicación
        viewModel.checkLocationAuthorization { [weak self] authorized in
            if authorized {
                self?.mapView.showsUserLocation = true
                self?.mapView.showsUserTrackingButton = true
                self?.viewModel.enableUserLocation()
            } else {
                self?.mapView.showsUserLocation = false
                self?.mapView.showsUserTrackingButton = false
            }
        }
    }
    
    // MARK: - Configuración
    private func setupMapView() {
        updateTitleForAnnotations()
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.isZoomEnabled = true
    }
    
    private func setupBindings() {
        viewModel.status.bind { [weak self] status in
            switch status {
            case .loading:
                break
            case .success:
                self?.updateMap()
                let buttonTitle = self?.viewModel.isNextButtonChangeText == true ? "Localización" : "Localizaciones"
                self?.nextButton.setTitle(buttonTitle, for: .normal)
            case .error(let message):
                self?.showErrorMessage(message)
            }
        }
    }
    
    // MARK: - Actualización del Mapa
    private func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(viewModel.annotations)
        
        if let firstAnnotation = viewModel.firstAnnotation {
            let region = MKCoordinateRegion(center: firstAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
            mapView.setRegion(region, animated: true)
            mapView.selectAnnotation(firstAnnotation, animated: true)
        }
    }
    
    // MARK: - IBActions
    @IBAction func didMoveToNextAnnotationTapped(_ sender: Any) {
        if let nextAnnotation = viewModel.nextAnnotation() {
            let region = MKCoordinateRegion(center: nextAnnotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
            mapView.setRegion(region, animated: true)
            mapView.selectAnnotation(nextAnnotation, animated: true)
        }
    }
    
    @IBAction func didToggleMapTapped(_ sender: Any) {
        mapView.mapType = viewModel.toggleMapType()
    }
    
    // MARK: - Métodos Auxiliares
    func configure(with annotations: [HeroAnnotation]) {
        viewModel.loadAnnotations(annotations)
    }
    
    private func updateTitleForAnnotations() {
        configureNavigationBar(title: "Localizaciones", backgroundColor: .systemBackground)
        title = viewModel.annotationCount == 1 ? "Localización" : "Localizaciones"
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let heroAnnotation = annotation as? HeroAnnotation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) as? HeroAnnotationView
        ?? HeroAnnotationView(annotation: heroAnnotation, reuseIdentifier: HeroAnnotationView.identifier)
        
        annotationView.configureButtonAction(target: self, action: #selector(streetViewButtonTapped(_:)))
        
        return annotationView
    }
    
    @objc private func streetViewButtonTapped(_ sender: UIButton) {
        // Buscar la vista de anotación
        var view: UIView? = sender
        while view != nil && !(view is MKAnnotationView) {
            view = view?.superview
        }
        
        guard let annotationView = view as? MKAnnotationView,
              let heroAnnotation = annotationView.annotation as? HeroAnnotation else {
            print("No se pudo obtener la anotación.")
            return
        }
        
        // Obtener la escena de Look Around usando el ViewModel
        viewModel.fetchLookAroundScene(for: heroAnnotation.coordinate) { [weak self] scene in
            DispatchQueue.main.async {
                if let scene = scene {
                    let streetViewVC = LookAroundViewController(viewModel: LookAroundViewModel(scene: scene))
                    streetViewVC.modalPresentationStyle = .fullScreen
                    self?.present(streetViewVC, animated: true)
                } else {
                    self?.showErrorMessage("Lo sentimos, esta localización no está cubierta por el servicio Look Around de Apple Maps.")
                }
            }
        }
    }
}
