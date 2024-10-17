//
//  APIHero.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

// MARK: - Model
struct ApiHero: Codable {
    let id: String?
    let name: String?
    let description: String?
    let photo: String?
    let favorite: Bool?
}
