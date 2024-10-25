//
//  DetailsHeroUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 18/10/24.
//

import Foundation

protocol DetailsHeroUseCaseProtocol {
    
    func loadLocationsForHeroWithId(id: String, completion: @escaping (Result<[Location], GAError>) -> Void)
    func loadTransformationsForHeroWithId(id: String, completion: @escaping (Result<[Transformation], GAError>) -> Void)
}

class DetailsHeroUseCase: DetailsHeroUseCaseProtocol {
    
    private var apiProvider: ApiProviderProtocol
    private var storeDataProvider: StoreDataProvider
    
    init(apiProvider: ApiProviderProtocol = ApiProvider(), storeDataProvider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataProvider = storeDataProvider
    }
    
    func loadLocationsForHeroWithId(id: String, completion: @escaping (Result<[Location], GAError>) -> Void) {
        guard let hero = self.getHeroWith(id: id) else {
            debugPrint("Hero with id \(id) not found")
            completion(.failure(.heroNotFound(heroId: id)))
            return
        }
        let bdLocations = hero.locations ?? []
        if bdLocations.isEmpty {
            apiProvider.loadLocations(id: id) { [weak self] result in
                switch result {
                case .success(let locations):
                    self?.storeDataProvider.add(locations: locations)
                    let bdLocations = hero.locations ?? []
                    let domainLocations = bdLocations.map({Location(moLocation: $0)})
                    completion(.success(domainLocations))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        } else {
            let domainLocations = bdLocations.map({Location(moLocation: $0)})
            completion(.success(domainLocations))
        }
        
        
    }
    
    private func getHeroWith(id: String) -> MOHero? {
        let predicate = NSPredicate(format: "id == %@", id)
        let heroes = storeDataProvider.fetchHeroes(filter: predicate)
        return heroes.first
    }
    
    // MARK: - Cargar transformaciones del héroe por id
    func loadTransformationsForHeroWithId(id: String, completion: @escaping (Result<[Transformation], GAError>) -> Void) {
        guard let hero = self.getHeroWith(id: id) else {
            debugPrint("Hero with id \(id) not found")
            completion(.failure(.heroNotFound(heroId: id)))
            return
        }
        
        let bdTransformations = hero.transformations ?? []
        
        // Si las transformaciones están vacías, hacer la llamada a la API
        if bdTransformations.isEmpty {
            apiProvider.loadTransformations(id: id) { [weak self] result in
                switch result {
                case .success(let transformations):
                    // Guardamos las transformaciones en la base de datos
                    self?.storeDataProvider.add(transformations: transformations)
                    
                    // Obtenemos las transformaciones de la BBDD nuevamente después de almacenarlas
                    let bdTransformations = hero.transformations ?? []
                    
                    // Convertimos a dominio y las ordenamos por nombre
                    let domainTransformations = bdTransformations.map({ Transformation(moTransformation: $0) })
                        .sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
                    
                    completion(.success(domainTransformations))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Si las transformaciones ya están en la BBDD, las convertimos y ordenamos
            let domainTransformations = bdTransformations.map({ Transformation(moTransformation: $0) })
                .sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
            
            completion(.success(domainTransformations))
        }
    }
    
    
}
