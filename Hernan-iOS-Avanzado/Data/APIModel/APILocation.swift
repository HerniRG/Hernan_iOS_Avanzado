//
//  APILocation.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

// MARK: - Model
struct ApiLocation: Codable {
    let id: String?
    let date: String?
    let latitude: String?
    let longitude: String?
    let hero: ApiHero?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case date = "dateShow"
        case latitude = "latitud" 
        case longitude = "longitud"
        case hero
    }
}
