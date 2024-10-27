//
//  MockData.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import Foundation
@testable import Hernan_iOS_Avanzado


/// Clase Helper para obtneer los data mock que necesitemos para los tests
class MockData {
    
    // Mock de héroes
    
    static func mockHeroes() throws -> [ApiHero] {
        let bundle = Bundle(for: MockData.self)
        guard let url = bundle.url(forResource: "Heroes", withExtension: "json") else {
            throw NSError(domain: "MockData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Heroes.json not found"])
        }
        let data = try Data(contentsOf: url)
        do {
            let heroes = try JSONDecoder().decode([ApiHero].self, from: data)
            return heroes
        } catch {
            print("Error decoding Heroes.json: \(error)")
            throw error
        }
    }
    
    
    
    static func loadHeroesData() throws -> Data {
        let heroes = try mockHeroes()
        let jsonData = try JSONEncoder().encode(heroes)
        return jsonData
    }
    
    // Mock de transformaciones
    static func mockTransformations() throws -> [ApiTransformation] {
        return [
            ApiTransformation(id: "1", name: "Super Saiyan", photo: "https://example.com/ss.jpg", description: "First transformation", hero: nil)
        ]
    }
    
    static func loadTransformationsData() throws -> Data {
        let transformations = try mockTransformations()
        let jsonData = try JSONEncoder().encode(transformations)
        return jsonData
    }
    
    // Mock de ubicaciones
    static func mockLocations() throws -> [ApiLocation] {
        return [
            ApiLocation(id: "1", date: "2024-10-22", latitude: "35.6895", longitude: "139.6917", hero: nil)
        ]
    }
    
    static func loadLocationsData() throws -> Data {
        let locations = try mockLocations()
        let jsonData = try JSONEncoder().encode(locations)
        return jsonData
    }
}
