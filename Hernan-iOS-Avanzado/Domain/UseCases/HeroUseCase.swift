//
//  HeroUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

/// Protocolo que define el caso de uso de Heroes
/// Este protocolo define la funcionalidad que proveerá los datos de Heroes,
/// ya sea desde una fuente local (base de datos) o remota (API).
protocol HeroUseCaseProtocol {
    
    /// Función para cargar los héroes, con un filtro opcional
    /// - Parameters:
    ///   - filter: Filtro opcional para buscar héroes por nombre
    ///   - completion: Closure que devuelve un `Result`, conteniendo un array de `Hero` en caso de éxito o un `GAError` en caso de fallo
    func loadHeros(filter: String?, completion: @escaping ((Result<[Hero], GAError>) -> Void))
}

class HeroUseCase: HeroUseCaseProtocol {
    
    // Proveedor de la API para obtener los héroes remotamente
    let apiProvider = ApiProvider()
    
    /// Implementación del caso de uso para cargar héroes
    /// - Parameters:
    ///   - filter: Filtro opcional para buscar héroes
    ///   - completion: Closure que devuelve un `Result` con el array de `Hero` o un error en caso de fallo
    func loadHeros(filter: String? = nil, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        // Primero, intentamos obtener los datos desde la base de datos local (Core Data)
        let bdHeroes = StoreDataProvider.shared.fetchHeroes(filter: nil)
        
        // Si tenemos datos en la base de datos, los devolvemos
        if !bdHeroes.isEmpty {
            // Mapeamos los MOHero (de Core Data) a Hero (modelo de dominio)
            let heroes = bdHeroes.map { Hero(moHero: $0) }
            // Devolvemos los héroes mapeados en el closure de éxito
            completion(.success(heroes))
        } else {
            // Si no hay datos en la base de datos, hacemos la petición a la API
            apiProvider.loadHeros { result in
                switch result {
                case .success(let apiHeroes):
                    // almacenar estos héroes en la base de datos
                    StoreDataProvider.shared.add(heroes: apiHeroes)
                    // Mapeamos los ApiHero (de la API) a Hero (modelo de dominio)
                    let heroes = apiHeroes.map { Hero(apiHero: $0) }
                    // Devolvemos los héroes mapeados en el closure de éxito
                    completion(.success(heroes))
                case .failure(let error):
                    // Si la API falla, devolvemos el error en el closure de fallo
                    completion(.failure(error))
                }
            }
        }
    }
}
