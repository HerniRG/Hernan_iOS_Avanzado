//
//  Hero.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

///Modelo de Domain Hero
///ES el que se usará en la capa de presentación
struct Hero {
    
    let id: String
    let name: String
    let photo: String
    let favorite: Bool
    
    
    ///Constructor para mapear un MOHero a un instancia de Hero
    init(moHero: MOHero) {
        self.id = moHero.id ?? ""
        self.name = moHero.name ?? ""
        self.photo = moHero.photo ?? ""
        self.favorite = moHero.favorite
    }
    
    /// Constructor para mapear un ApiHero a una instancia de Hero (de la API a dominio)
    init(apiHero: ApiHero) {
        self.id = apiHero.id ?? ""
        self.name = apiHero.name ?? ""
        self.photo = apiHero.photo ?? ""
        self.favorite = apiHero.favorite ?? false
    }
}
