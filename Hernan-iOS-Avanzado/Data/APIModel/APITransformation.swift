//
//  APITransformation.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

struct ApiTransformation: Codable {
    let id: String?
    let name: String?
    let photo: String?
    let description: String?
    let hero: ApiHero?
}
