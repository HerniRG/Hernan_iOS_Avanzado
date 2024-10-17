//
//  ClearDataBaseUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

/// Protocolo que define el caso de uso para limpiar la base de datos.
protocol ClearDatabaseAndTokenUseCaseProtocol {
    /// Limpia la base de datos y devuelve un resultado a través del completion handler.
    /// - Parameter completion: Closure que devuelve un `Result` indicando éxito o error.
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void)
}

class ClearDatabaseAndTokenUseCase: ClearDatabaseAndTokenUseCaseProtocol {
    
    // Proveedor de datos locales (por ejemplo, Core Data)
    private var storeDataProvider: StoreDataProvider
    private var secureDataStore: SecureDataStore
    
    /// Inicializador del caso de uso para limpiar la base de datos.
    /// - Parameter storeDataProvider: Proveedor de almacenamiento local (por defecto, `StoreDataProvider.shared`).
    init(storeDataProvider: StoreDataProvider = .shared, secureDataStore: SecureDataStore = .shared) {
        self.storeDataProvider = storeDataProvider
        self.secureDataStore = secureDataStore
    }
    
    /// Implementación para limpiar la base de datos.
    /// - Parameter completion: Closure que devuelve un `Result` con `Void` en caso de éxito, o un `GAError` en caso de fallo.
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void) {
        // Intentamos ejecutar la función clearBBDD
        do {
            try storeDataProvider.clearBBDD()
            secureDataStore.deleteToken()
            completion(.success(())) // Si tiene éxito, devolvemos un Result.success
        } catch {
            // En caso de error, devolvemos un Result.failure con un GAError para Core Data
            completion(.failure(.coreDataError(error: error)))
        }
    }
}
