//
//  APIHero.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

/// Modelo Hero de la Api
struct ApiHero: Codable {
    let id: String?
    let name: String?
    let photo: String?
    let favorite: Bool?
}
