//
//  ClearDataBaseUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

// MARK: - Protocol Definition
/// Protocolo que define el caso de uso para limpiar la base de datos.
protocol ClearDatabaseAndTokenUseCaseProtocol {
    /// Limpia la base de datos y devuelve un resultado a través del completion handler.
    /// - Parameter completion: Closure que devuelve un `Result` indicando éxito o error.
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void)
}

// MARK: - ClearDatabaseAndTokenUseCase Implementation
class ClearDatabaseAndTokenUseCase: ClearDatabaseAndTokenUseCaseProtocol {
    
    private var storeDataProvider: StoreDataProvider
    private var secureDataStore: SecureDataStoreProtocol // Cambia a SecureDataStoreProtocol
    
    init(storeDataProvider: StoreDataProvider = .shared, secureDataStore: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.storeDataProvider = storeDataProvider
        self.secureDataStore = secureDataStore
    }
    
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void) {
        do {
            try storeDataProvider.clearBBDD() // Intentamos limpiar la base de datos
            secureDataStore.deleteToken() // Eliminar token
            completion(.success(())) // Devolver éxito si todo fue bien
        } catch {
            completion(.failure(GAError.coreDataError(error: error))) // Devolver error si ocurre un fallo
        }
    }
}
