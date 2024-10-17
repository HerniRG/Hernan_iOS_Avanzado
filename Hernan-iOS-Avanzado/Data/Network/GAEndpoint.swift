//  GAEndpoint.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

/// Enum de los endpoints de la app
enum GAEndpoint {
    case heroes
    case locations
    case transformations
    case login
    
    /// Función para obtener el path
    /// - Returns: Devuelve el path para el endpoint en cuestión
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        case .transformations:
            return "/api/heros/tranformations"
        case .login:
            return "/api/auth/login" 
        }
    }
    
    /// Función para obtener el httpmethod
    /// - Returns: Devuelve el HTTPMethod a utilizar con cada endpoint
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations, .transformations, .login:
            return "POST"
        }
    }
}
