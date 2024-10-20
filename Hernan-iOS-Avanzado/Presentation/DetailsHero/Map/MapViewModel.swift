//
//  MapViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import Foundation
import MapKit

enum MapViewStatus {
    case loading
    case success
    case error(msg: String)
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

class MapViewModel {
    
    private(set) var annotations: [HeroAnnotation] = []
    private var currentAnnotationIndex = 0
    private var currentMapType: MapTypeState = .standard
    var status: GAObservable<MapViewStatus> = GAObservable(.loading)
    
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
        self.status.value = .success
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
}
