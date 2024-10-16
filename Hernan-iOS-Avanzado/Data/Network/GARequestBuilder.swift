//
//  GARequestBuilder.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

/// Builder que construirá la request a usar en la pi a partir de un endpoint,
/// Y parámtros dado
class GARequestBuilder {
    ///Host del api
    private let host = "dragonball.keepcoding.education"
    private var request: URLRequest?
    /// Token de session de momento es una constante, pasará aobtenerse del KeyChain
    var token: String? {
        secureStorage.getToken()
    }
    
    private let secureStorage: SecureDataStoreProtocol
    
    init(secureStorage: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.secureStorage = secureStorage
    }
    
    /// Función para obtener la url del request
    /// - Parameter endoPoint: endpoint para el que se crea la url
    /// - Returns: LA url a partirr de URLComponents
    private func url(endoPoint: GAEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endoPoint.path()
        return components.url
    }

    
    ///  Configura los headers de la request
    ///  Parameter params: Parámetros que deben ir en el body
    /// Añade el header de Authorization ( Ver si es necesario siempre)
    private func setHeaders(params:[String: String]?) {
        request?.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        if let params {
            request?.httpBody = try? JSONSerialization.data(withJSONObject: params)
        }
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    
    /// Compone la request a partir de los parámetros recibidos
    /// - Parameters:
    ///   - endPoint: GAEndpoint para el que crea la request
    ///   - params: parámetros para el body de la request.
    /// - Returns: DEvuelve uan URLREquest, compuesta a partir de los métodos de la clase
    func buildRequest(endPoint: GAEndpoint, params:[String: String]) -> URLRequest? {
        guard let url = self.url(endoPoint: endPoint), let _ = self.token else {
            return nil
        }
        request = URLRequest(url: url)
        request?.httpMethod = endPoint.httpMethod()
        setHeaders(params: params)
        
        return request
    }
}
