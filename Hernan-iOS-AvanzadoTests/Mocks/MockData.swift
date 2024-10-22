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
    
    /// DEvuelve el DATA del json
    static func loadHeroesData() throws -> Data {
        let bundle = Bundle(for: MockData.self)
        guard let url = bundle.url(forResource: "Heroes", withExtension: "json"),
              let data = try? Data.init(contentsOf: url)  else {
            throw NSError(domain: "io.keepcoding.GokuandrRiends", code: -1)
        }
        return data
    }
    
    
    /// A partir del Data de heroes crea y devuelve el array de ApiHero
    static func mockHeroes() throws -> [ApiHero] {
        do {
            let data = try self.loadHeroesData()
            let heroes = try JSONDecoder().decode([ApiHero].self, from: data)
            return heroes
        } catch {
            throw error
        }
    }
}
