//
//  DetailsTransformationViewModelTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado
import CoreData

class DetailsTransformationViewModelTests: XCTestCase {
    
    var sut: DetailsTransformationViewModel!
    var transformation: Transformation!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Crear un objeto de transformación de prueba
        let mockTransformationEntity = MOTransformation(context: mockManagedObjectContext)
        mockTransformationEntity.id = "trans1"
        mockTransformationEntity.name = "Super Saiyan"
        mockTransformationEntity.photo = "https://example.com/super_saiyan.jpg"
        mockTransformationEntity.info = "Increases power"
        
        // Inicializar el objeto de transformación con la entidad mock
        transformation = Transformation(moTransformation: mockTransformationEntity)
        
        // Inicializar el ViewModel con la transformación de prueba
        sut = DetailsTransformationViewModel(transformation: transformation)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        transformation = nil
        try super.tearDownWithError()
    }
    
    func test_GetTransformationName_ReturnsCorrectName() {
        // When
        let name = sut.getTransformationName()
        
        // Then
        XCTAssertEqual(name, transformation.name, "El nombre de la transformación debería ser \(transformation.name)")
    }
    
    func test_GetTransformationDescription_ReturnsCorrectDescription() {
        // When
        let description = sut.getTransformationDescription()
        
        // Then
        XCTAssertEqual(description, transformation.description, "La descripción de la transformación debería ser \(transformation.description)")
    }
    
    func test_GetTransformationPhotoURL_ReturnsValidURL() {
        // When
        let photoURL = sut.getTransformationPhotoURL()
        
        // Then
        XCTAssertNotNil(photoURL, "La URL de la foto no debería ser nil")
        XCTAssertEqual(photoURL?.absoluteString, transformation.photo, "La URL de la foto debería ser \(transformation.photo)")
    }
    
    func test_GetTransformationPhotoURL_ReturnsNil_ForInvalidURL() {
        // Dando una transformación con una URL inválida
        let invalidTransformationEntity = MOTransformation(context: mockManagedObjectContext)
        invalidTransformationEntity.id = "trans1"
        invalidTransformationEntity.name = "Invalid Transformation"
        invalidTransformationEntity.photo = nil // URL no válida
        invalidTransformationEntity.info = "This should not work"

        // Inicializar el ViewModel con la transformación inválida
        transformation = Transformation(moTransformation: invalidTransformationEntity)
        sut = DetailsTransformationViewModel(transformation: transformation)
        
        // When
        let photoURL = sut.getTransformationPhotoURL()
        
        // Then
        XCTAssertNil(photoURL, "La URL de la foto debería ser nil para una URL inválida")
    }
}
