//
//  GARequestBuilder.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

// MARK: - GARequestBuilder
class GARequestBuilder {
    
    /// Host del API
    private let host = "dragonball.keepcoding.education"
    private var request: URLRequest?
    
    /// Token de sesión que se obtiene desde el KeyChain (SecureDataStore)
    var token: String? {
        secureStorage.getToken()
    }
    
    private let secureStorage: SecureDataStoreProtocol
    
    // MARK: - Initializer
    /// Inicializador que inyecta `SecureDataStore`
    init(secureStorage: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.secureStorage = secureStorage
    }
    
    // MARK: - URL Generation
    /// Función para obtener la URL del request
    /// - Parameter endPoint: Endpoint para el que se crea la URL
    /// - Returns: La URL a partir de URLComponents
    private func url(endPoint: GAEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endPoint.path()
        return components.url
    }
    
    // MARK: - Header Configuration
    /// Configura los headers de la request
    /// - Parameters:
    ///   - params: Parámetros que deben ir en el body
    ///   - requiresToken: Indica si el token de autorización es necesario para esta petición
    private func setHeaders(params: [String: String]?, requiresToken: Bool) throws {
        if requiresToken, let token = self.token {
            request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let params {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params)
                request?.httpBody = jsonData
            } catch {
                throw GAError.errorParsingData
            }
        }
        
        // Configuración de tipo de contenido
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    // MARK: - Request Building
    /// Compone la request a partir de los parámetros recibidos
    /// - Parameters:
    ///   - endPoint: GAEndpoint para el que se crea la request
    ///   - params: Parámetros para el body de la request.
    ///   - requiresToken: Indica si la request necesita el token de autenticación
    /// - Returns: Devuelve una URLRequest, compuesta a partir de los métodos de la clase
    func buildRequest(endPoint: GAEndpoint, params: [String: String], requiresToken: Bool = true) -> URLRequest? {
        // Aseguramos que la URL se crea correctamente y que, si requiere token, exista el token
        guard let url = self.url(endPoint: endPoint), !requiresToken || self.token != nil else {
            return nil
        }
        
        // Creamos la request
        request = URLRequest(url: url)
        request?.httpMethod = endPoint.httpMethod()
        
        // Configuramos los headers
        do {
            try setHeaders(params: params, requiresToken: requiresToken)
        } catch {
            return nil
        }
        
        return request
    }
}
