//
//  Hero.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

///Modelo de Domain Hero
///ES el que se usará en la capa de presentación
struct Hero: Hashable {
    
    let id: String
    let name: String
    let info: String
    let photo: String
    let favorite: Bool
    
    
    ///Constructor para mapear un MOHero a un instancia de Hero
    init(moHero: MOHero) {
        self.id = moHero.id ?? ""
        self.name = moHero.name ?? ""
        self.info = moHero.info ?? ""
        self.photo = moHero.photo ?? ""
        self.favorite = moHero.favorite
    }
    
    /// Constructor para mapear un ApiHero a una instancia de Hero (de la API a dominio)
    init(apiHero: ApiHero) {
        self.id = apiHero.id ?? ""
        self.name = apiHero.name ?? ""
        self.info = apiHero.description ?? ""
        self.photo = apiHero.photo ?? ""
        self.favorite = apiHero.favorite ?? false
    }
}
