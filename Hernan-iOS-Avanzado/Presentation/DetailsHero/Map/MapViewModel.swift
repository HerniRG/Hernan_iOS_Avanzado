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

class MapViewModel {
    
    private var annotations: [HeroAnnotation] = []
    private var currentAnnotationIndex = 0
    var status: GAObservable<MapViewStatus> = GAObservable(.loading)
    
    var mapAnnotations: [HeroAnnotation] {
        return annotations
    }
    
    var isNextButtonHidden: Bool {
        return annotations.count <= 1
    }
    
    // Cargar las anotaciones y cambiar el estado a éxito
    func loadAnnotations(_ annotations: [HeroAnnotation]) {
        self.annotations = annotations
        status.value = annotations.isEmpty ? .error(msg: "No hay anotaciones") : .success
    }
    
    // Obtener la siguiente anotación
    func nextAnnotation() -> HeroAnnotation? {
        guard !annotations.isEmpty else { return nil }
        currentAnnotationIndex = (currentAnnotationIndex + 1) % annotations.count
        return annotations[currentAnnotationIndex]
    }
}
