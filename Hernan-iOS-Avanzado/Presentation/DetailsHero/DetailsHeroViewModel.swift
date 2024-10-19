//
//  DetailsHeroViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 18/10/24.
//

enum StatusDetailsHero {
    case loading
    case success
    case error(msg: String)
}

class DetailsHeroViewModel {
    
    private(set) var hero: Hero
    private(set) var transformations: [Transformation] = []
    private var heroLocations: [Location] = []
    private var useCase: DetailsHeroUseCaseProtocol
    
    var annotations: [HeroAnnotation] = []
    var status: GAObservable<StatusDetailsHero> = GAObservable(.loading)
    
    init(hero: Hero, useCase: DetailsHeroUseCaseProtocol = DetailsHeroUseCase()) {
        self.hero = hero
        self.useCase = useCase
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
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    // Actualizar las anotaciones del mapa
    private func updateAnnotations() {
        self.annotations = heroLocations.compactMap { location in
            guard let coordinate = location.coordinate else { return nil }
            return HeroAnnotation(coordinate: coordinate, title: self.hero.name)
        }
        self.status.value = .success // Cambiar estado a éxito después de actualizar
    }
    
    // MARK: - Cargar transformaciones del héroe
    private func loadTransformations() {
        useCase.loadTransformationsForHeroWithId(id: hero.id) { [weak self] result in
            switch result {
            case .success(let transformations):
                self?.transformations = transformations
                self?.status.value = .success
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    // Manejar errores
    private func handleError(_ error: GAError) {
        status.value = .error(msg: error.description)
    }
}
