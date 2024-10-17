//
//  GARequestBuilder.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

/// Builder que construirá la request a usar en la API a partir de un endpoint,
/// y parámetros dados.
class GARequestBuilder {
    /// Host del API
    private let host = "dragonball.keepcoding.education"
    private var request: URLRequest?
    
    /// Token de sesión que se obtiene desde el KeyChain (SecureDataStore)
    var token: String? {
        secureStorage.getToken()
    }
    
    private let secureStorage: SecureDataStoreProtocol
    
    /// Inicializador que inyecta `SecureDataStore`
    init(secureStorage: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.secureStorage = secureStorage
    }
    
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
        
        // Verificar que el tipo de contenido sea JSON
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Añadir cabecera Accept
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Request body: \(String(data: request?.httpBody ?? Data(), encoding: .utf8) ?? "No body")")
    }

    
    /// Compone la request a partir de los parámetros recibidos
    /// - Parameters:
    ///   - endPoint: GAEndpoint para el que se crea la request
    ///   - params: Parámetros para el body de la request.
    ///   - requiresToken: Indica si la request necesita el token de autenticación
    /// - Returns: Devuelve una URLRequest, compuesta a partir de los métodos de la clase
    func buildRequest(endPoint: GAEndpoint, params: [String: String], requiresToken: Bool = true) -> URLRequest? {
        // Aseguramos que la URL se crea correctamente y, si requiere token, que exista el token
        guard let url = self.url(endPoint: endPoint), !requiresToken || self.token != nil else {
            return nil
        }
        
        // Creamos la request
        request = URLRequest(url: url)
        request?.httpMethod = endPoint.httpMethod()
        
        // Configuramos los headers, capturando cualquier error en el proceso
        do {
            try setHeaders(params: params, requiresToken: requiresToken)
        } catch {
            print("Error configurando los headers: \(error.localizedDescription)")
            return nil
        }
        
        return request
    }
}
