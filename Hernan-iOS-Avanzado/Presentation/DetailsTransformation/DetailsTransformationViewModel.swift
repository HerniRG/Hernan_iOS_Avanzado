//
//  DetailsTransformationViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 20/10/24.
//

import Foundation

class DetailsTransformationViewModel {
    
    // MARK: - Properties
    private var transformation: Transformation
    
    // MARK: - Initializer
    init(transformation: Transformation) {
        self.transformation = transformation
    }
    
    // MARK: - Obtener los datos de la transformación
    func getTransformationName() -> String {
        return transformation.name
    }
    
    func getTransformationDescription() -> String {
        return transformation.description
    }
    
    func getTransformationPhotoURL() -> URL? {
        // Comprobar si la cadena está vacía
        if transformation.photo.isEmpty {
            return nil
        }
        // Retorna la URL si es válida
        return URL(string: transformation.photo)
    }
}
