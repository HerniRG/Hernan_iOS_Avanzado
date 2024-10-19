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
    
    private let hero: Hero
    private var heroLocations: [Location] = []
    private var useCase: DetailsHeroUseCaseProtocol
    
    var annotations: [HeroAnnotation] = []
    
    var status: GAObservable<StatusDetailsHero> = GAObservable(.loading)
    
    init(hero: Hero,useCase: DetailsHeroUseCaseProtocol = DetailsHeroUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    var heroName: String {
        return hero.name
    }
    
    var heroPhoto: String {
        return hero.photo
    }
    
    var heroInfo: String {
        return hero.info
    }
    
    func loadData() {
        loadLocations()
    }
    
    private func loadLocations() {
        useCase.loadLocationsForHeroWithId(id: hero.id) { [weak self] result in
            switch result {
            case .success(let locations):
                self?.heroLocations = locations
                self?.createAnnotations()
            case .failure(let error):
                self?.status.value = .error(msg: error.description)
            }
        }
    }
    
    private func createAnnotations() {
        self.annotations = []
        heroLocations.forEach { [weak self] location in
            guard let coordinate = location.coordinate else { return }
            let annotation = HeroAnnotation(coordinate: coordinate, title: self?.hero.name)
            self?.annotations.append(annotation)
        }
        self.status.value = .success
    }
}
