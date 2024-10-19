//
//  GAError.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

/// Enum de errores que gestionamos en la app
/// Implementa CustomStringConvertible para personalizar la descripción del error
enum GAError: Error, CustomStringConvertible {
    
    case requestWasNil
    case errorFromServer(error: Error)
    case errorFromApi(statusCode: Int)
    case noDataReceived
    case errorParsingData
    case coreDataError(error: Error)
    case authenticationFailed
    case sessionTokenMissing
    case badUrl
    case heroNotFound(heroId: String)
    
    // MARK: - Error Description
    var description: String {
        switch self {
        case .requestWasNil:
            return "Error creating request"
        case .errorFromServer(error: let error):
            return "Received error from server \((error as NSError).code)"
        case .errorFromApi(statusCode: let code):
            return "Received error from API status code \(code)"
        case .noDataReceived:
            return "No data received from server"
        case .errorParsingData:
            return "There was an error parsing data"
        case .coreDataError(error: let error):
            return "Core Data error: \((error as NSError).localizedDescription)"
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials"
        case .sessionTokenMissing:
            return "Session token missing"
        case .badUrl:
            return "Bad URL"
        case .heroNotFound(heroId: let heroId):
            return "Hero with id \(heroId) not found"
        }
    }
}
