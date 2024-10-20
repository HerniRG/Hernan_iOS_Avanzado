//
//  DetailsTransformationViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 20/10/24.
//

import Foundation

class DetailsTransformationViewModel {
    
    // MARK: - Properties
    private(set) var transformation: Transformation
    
    // MARK: - Initializer
    init(transformation: Transformation) {
        self.transformation = transformation
    }
    
    // MARK: - Accessor para obtener los datos de la transformación
    func getTransformationName() -> String {
        return transformation.name
    }
    
    func getTransformationDescription() -> String {
        return transformation.description
    }
    
    func getTransformationPhotoURL() -> URL? {
        return URL(string: transformation.photo)
    }
}
