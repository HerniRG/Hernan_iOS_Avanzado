//
//  HeroUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

// MARK: - Protocol Definition
/// Protocolo que define el caso de uso de Héroes
protocol HeroUseCaseProtocol {
    
    /// Función para cargar los héroes, con un filtro opcional.
    /// - Parameters:
    ///   - filter: Filtro opcional (NSPredicate) para buscar héroes.
    ///   - completion: Closure que devuelve un `Result` con un array de `Hero` o un `GAError`.
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void))
}

// MARK: - HeroUseCase Implementation
class HeroUseCase: HeroUseCaseProtocol {
    
    private var apiProvider: any ApiProviderProtocol
    private var storeDataProvider: StoreDataProvider
    
    // MARK: - Initializer
    /// Inicializador de `HeroUseCase`
    /// - Parameters:
    ///   - apiProvider: Proveedor de API para cargar datos remotos.
    ///   - storeDataProvider: Proveedor de almacenamiento local.
    init(apiProvider: any ApiProviderProtocol = ApiProvider(), storeDataProvider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataProvider = storeDataProvider
    }
    
    // MARK: - Load Heroes Function
    /// Implementación del caso de uso para cargar héroes desde una fuente local o remota.
    /// - Parameters:
    ///   - filter: Filtro opcional para buscar héroes en la base de datos.
    ///   - completion: Closure que devuelve un `Result` con el array de `Hero` o un `GAError`.
    func loadHeros(filter: NSPredicate? = nil, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        
        let bdHeroes = storeDataProvider.fetchHeroes(filter: filter)
        
        if !bdHeroes.isEmpty {
            let heroes = bdHeroes.map { Hero(moHero: $0) } // Mapeo de MOHero a Hero
            completion(.success(heroes)) // Devolvemos héroes de la BD
        } else {
            apiProvider.loadHeros(name: filter?.predicateFormat ?? "") { [weak self] result in
                switch result {
                case .success(let apiHeroes):
                    self?.storeDataProvider.add(heroes: apiHeroes) // Guardamos héroes en la BD
                    let heroes = apiHeroes.map { Hero(apiHero: $0) } // Mapeo de ApiHero a Hero
                    completion(.success(heroes)) // Devolvemos héroes de la API
                case .failure(let error):
                    completion(.failure(error)) // Error en la API
                }
            }
        }
    }
}
