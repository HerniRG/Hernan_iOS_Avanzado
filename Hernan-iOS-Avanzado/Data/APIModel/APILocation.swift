//
//  APILocation.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

/// Modelo Location de la Api
struct ApiLocation: Codable {
    let id: String?
    let date: String?
    let latitude: String?
    let longitude: String?
    let hero: ApiHero?
    
    /// Usamos CondingKey para mapear los atributos a los valores que devuelve la api
    enum CodingKeys: String, CodingKey {
        case id
        case date = "dateShow"
        case latitude = "latitud"
        case longitude = "longitud"
        case hero
    }
}
