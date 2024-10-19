//
//  Transformation.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import Foundation

// MARK: - Domain Model: Transformation
/// Modelo de Domain Transformation
/// Este es el que se usará en la capa de presentación.
struct Transformation: Hashable {
    
    let id: String
    let name: String
    let description: String
    let photo: String
    
    // MARK: - Initializers
    
    /// Constructor para mapear un MOTransformation a una instancia de Transformation.
    init(moTransformation: MOTransformation) {
        self.id = moTransformation.id ?? ""
        self.name = moTransformation.name ?? ""
        self.description = moTransformation.info ?? "" 
        self.photo = moTransformation.photo ?? ""
    }
    
    /// Constructor para mapear un ApiTransformation a una instancia de Transformation (de la API a dominio).
    init(apiTransformation: ApiTransformation) {
        self.id = apiTransformation.id ?? ""
        self.name = apiTransformation.name ?? ""
        self.description = apiTransformation.description ?? ""
        self.photo = apiTransformation.photo ?? ""
    }
}
