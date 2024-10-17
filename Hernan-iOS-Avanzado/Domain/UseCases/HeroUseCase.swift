//
//  HeroUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

/// Protocolo que define el caso de uso de Héroes
/// Este protocolo proporciona la funcionalidad para obtener héroes,
/// ya sea desde una fuente local (como una base de datos) o remota (API).
protocol HeroUseCaseProtocol {
    
    /// Función para cargar los héroes, con un filtro opcional.
    /// - Parameters:
    ///   - filter: Filtro opcional (NSPredicate) para buscar héroes por nombre u otros criterios.
    ///   - completion: Closure que devuelve un `Result`, con un array de `Hero` en caso de éxito, o un `GAError` en caso de fallo.
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void))
}

class HeroUseCase: HeroUseCaseProtocol {
    
    // Proveedor de API para obtener los héroes desde una fuente remota (API)
    private var apiProvider: any ApiProviderProtocol
    // Proveedor de datos locales (por ejemplo, Core Data)
    private var storeDataProvider: StoreDataProvider
    
    /// Inicializador de `HeroUseCase`
    /// - Parameters:
    ///   - apiProvider: Proveedor de API para cargar datos remotos (se inyecta, con valor por defecto `ApiProvider`).
    ///   - storeDataProvider: Proveedor de almacenamiento local compartido (se inyecta, con valor por defecto `.shared`).
    init(apiProvider: any ApiProviderProtocol = ApiProvider(), storeDataProvider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataProvider = storeDataProvider
    }
    
    /// Implementación del caso de uso para cargar héroes desde una fuente local o remota.
    /// - Parameters:
    ///   - filter: Filtro opcional para buscar héroes en la base de datos.
    ///   - completion: Closure que devuelve un `Result` con el array de `Hero` o un `GAError` si hay un fallo.
    func loadHeros(filter: NSPredicate? = nil, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        
        // Intentamos obtener los datos desde la base de datos local usando el filtro (si existe)
        let bdHeroes = storeDataProvider.fetchHeroes(filter: filter)
        
        // Si se encuentran datos en la base de datos local, los devolvemos
        if !bdHeroes.isEmpty {
            // Mapeamos los `MOHero` (entidad de Core Data) a `Hero` (modelo de dominio)
            let heroes = bdHeroes.map { Hero(moHero: $0) }
            // Devolvemos los héroes en el closure de éxito
            completion(.success(heroes))
        } else {
            // Si no hay datos en la base de datos, se realiza una solicitud a la API
            apiProvider.loadHeros(name: filter?.predicateFormat ?? "") { [weak self] result in
                switch result {
                case .success(let apiHeroes):
                    // Guardamos los héroes obtenidos desde la API en la base de datos local
                    self?.storeDataProvider.add(heroes: apiHeroes)
                    // Mapeamos los `ApiHero` (desde la API) a `Hero` (modelo de dominio)
                    let heroes = apiHeroes.map { Hero(apiHero: $0) }
                    // Devolvemos los héroes mapeados en el closure de éxito
                    completion(.success(heroes))
                case .failure(let error):
                    // Si la llamada a la API falla, devolvemos el error en el closure de fallo
                    completion(.failure(error))
                }
            }
        }
    }
}
