//
//  DetailsHeroViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 18/10/24.
//

import Foundation

enum StatusDetailsHero: Equatable {
    case loading
    case success
    case error(msg: String)
}

class DetailsHeroViewModel {
    
    private var hero: Hero
    private var transformations: [Transformation] = []
    private var heroLocations: [Location] = []
    private var annotations: [HeroAnnotation] = []
    private var useCase: DetailsHeroUseCaseProtocol
    private var locationsLoaded = false
    private var transformationsLoaded = false
    
    var status: GAObservable<StatusDetailsHero> = GAObservable(.loading)
    
    init(hero: Hero, useCase: DetailsHeroUseCaseProtocol = DetailsHeroUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    // Función para acceder a 'hero'
    func getHero() -> Hero {
        return hero
    }
    
    // Función para acceder a 'transformations'
    func getTransformations() -> [Transformation] {
        return transformations
    }
    
    // Función para acceder a 'annotations'
    func getAnnotations() -> [HeroAnnotation] {
        return annotations
    }
    
    // Cargar tanto las localizaciones como las transformaciones del héroe
    func loadData() {
        status.value = .loading // Comienza en estado de carga
        loadLocations()
        loadTransformations()
    }
    
    // MARK: - Cargar localizaciones del héroe
    private func loadLocations() {
        useCase.loadLocationsForHeroWithId(id: hero.id) { [weak self] result in
            switch result {
            case .success(let locations):
                self?.heroLocations = locations
                self?.updateAnnotations()
                self?.locationsLoaded = true
                self?.checkDataLoadCompletion()
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    // Actualizar las anotaciones del mapa
    private func updateAnnotations() {
        self.annotations = heroLocations.compactMap { location in
            guard let coordinate = location.coordinate else { return nil }
            
            // Llamar a la función de formateo de la fecha
            let formattedDate = formatDate(location.date)
            
            // Aquí pasamos el dateShow formateado como subtítulo
            return HeroAnnotation(coordinate: coordinate, title: self.hero.name, subtitle: formattedDate)
        }
        self.status.value = .success
    }
    
    // Función para formatear la fecha
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Fecha no disponible" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d MMM yyyy"
            return dateFormatter.string(from: date)
        } else {
            return "Fecha no disponible"
        }
    }
    // MARK: - Cargar transformaciones del héroe
    private func loadTransformations() {
        useCase.loadTransformationsForHeroWithId(id: hero.id) { [weak self] result in
            switch result {
            case .success(let transformations):
                self?.transformations = transformations
                self?.transformationsLoaded = true
                self?.checkDataLoadCompletion()
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    private func checkDataLoadCompletion() {
        if locationsLoaded && transformationsLoaded {
            status.value = .success
        }
    }
    
    func transformationAt(index: Int) -> Transformation? {
        return index < transformations.count ? transformations[index] : nil
    }
    
    // Manejar errores
    private func handleError(_ error: GAError) {
        status.value = .error(msg: error.description)
    }
}
