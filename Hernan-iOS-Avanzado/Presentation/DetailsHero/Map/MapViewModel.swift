//
//  MapViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import Foundation
import MapKit

enum MapViewStatus: Equatable {
    case loading
    case success
    case error(message: String)
}

enum MapTypeState {
    case standard, satellite, hybrid
    
    func next() -> MapTypeState {
        switch self {
        case .standard: return .satellite
        case .satellite: return .hybrid
        case .hybrid: return .standard
        }
    }
    
    func toMKMapType() -> MKMapType {
        switch self {
        case .standard: return .standard
        case .satellite: return .satellite
        case .hybrid: return .hybrid
        }
    }
}

class MapViewModel: NSObject {
    private(set) var annotations: [HeroAnnotation] = []
    private var currentAnnotationIndex = 0
    private var currentMapType: MapTypeState = .standard
    var status: GAObservable<MapViewStatus> = GAObservable(.loading)
    var locationManager: CLLocationManager?
    var onAnnotationsUpdated: (() -> Void)?
    
    var isNextButtonChangeText: Bool {
        return annotations.count <= 1
    }
    
    // Propiedad calculada para obtener la primera anotación
    var firstAnnotation: HeroAnnotation? {
        return annotations.first
    }
    
    // Cambiar el tipo de mapa
    func toggleMapType() -> MKMapType {
        currentMapType = currentMapType.next()
        return currentMapType.toMKMapType()
    }
    
    // Cargar las anotaciones
    func loadAnnotations(_ annotations: [HeroAnnotation]) {
        self.annotations = annotations
        status.value = .success
    }
    
    // Obtener la siguiente anotación
    func nextAnnotation() -> HeroAnnotation? {
        guard !annotations.isEmpty else { return nil }
        currentAnnotationIndex = (currentAnnotationIndex + 1) % annotations.count
        return annotations[currentAnnotationIndex]
    }
    
    // Contador de anotaciones
    var annotationCount: Int {
        return annotations.count
    }
    
    // Obtener la coordenada de una anotación dada
    func getCoordinate(for annotation: HeroAnnotation) -> CLLocationCoordinate2D? {
        return annotation.coordinate
    }
    
    // MARK: - Manejo de Autorización de Ubicación
    
    func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func enableUserLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    // Obtener la escena de Look Around para una coordenada
    func fetchLookAroundScene(for coordinate: CLLocationCoordinate2D, completion: @escaping (MKLookAroundScene?) -> Void) {
        let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        sceneRequest.getSceneWithCompletionHandler { scene, error in
            if let error = error {
                print("Error al obtener la escena de Look Around: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(scene)
            }
        }
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Manejar cambios en la autorización si es necesario
    }
}
