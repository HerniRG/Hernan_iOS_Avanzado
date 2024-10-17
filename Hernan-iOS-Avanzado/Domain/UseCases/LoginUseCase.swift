//
//  LoginUseCase.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 17/10/24.
//

import Foundation

/// Protocolo que define el caso de uso de login.
protocol LoginUseCaseProtocol {
    /// Realiza la autenticación del usuario.
    /// - Parameters:
    ///   - username: Nombre de usuario.
    ///   - password: Contraseña.
    ///   - completion: Closure que devuelve un `Result` con `Void` si el login tiene éxito o un `GAError` en caso de fallo.
    func login(username: String, password: String, completion: @escaping (Result<Void, GAError>) -> Void)
}

class LoginUseCase: LoginUseCaseProtocol {
    
    private let apiProvider: ApiProviderProtocol
    private let secureDataStore: SecureDataStoreProtocol
    
    /// Inicializador del caso de uso de login.
    /// - Parameters:
    ///   - apiProvider: Proveedor de API inyectado, por defecto `ApiProvider`.
    ///   - secureDataStore: Almacenamiento seguro para el token.
    init(apiProvider: ApiProviderProtocol = ApiProvider(), secureDataStore: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.apiProvider = apiProvider
        self.secureDataStore = secureDataStore
    }
    
    /// Implementación del login.
    /// - Parameters:
    ///   - username: Nombre de usuario.
    ///   - password: Contraseña.
    ///   - completion: Closure que devuelve un `Result` con `Void` si tiene éxito, o un `GAError` en caso de fallo.
    func login(username: String, password: String, completion: @escaping (Result<Void, GAError>) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            completion(.failure(.errorParsingData))
            return
        }

        apiProvider.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let token):
                self?.secureDataStore.setToken(token) // Guarda el token directamente
                completion(.success(())) // Login exitoso
            case .failure(let error):
                completion(.failure(error)) // Manejo de error
            }
        }
    }
}
