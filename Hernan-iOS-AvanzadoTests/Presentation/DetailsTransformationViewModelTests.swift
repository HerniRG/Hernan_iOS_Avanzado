//
//  DetailsTransformationViewModelTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado
import CoreData

final class DetailsTransformationViewModelTests: XCTestCase {
    
    var sut: DetailsTransformationViewModel!
    var transformation: Transformation!
    
    override func setUpWithError() throws {
        // Configuración inicial: Crear un objeto de transformación de prueba con contexto de Core Data simulado
        try super.setUpWithError()
        
        let mockTransformationEntity = MOTransformation(context: mockManagedObjectContext)
        mockTransformationEntity.id = "trans1"
        mockTransformationEntity.name = "Super Saiyan"
        mockTransformationEntity.photo = "https://example.com/super_saiyan.jpg"
        mockTransformationEntity.info = "Increases power"
        
        // Inicializamos la transformación y el ViewModel con los datos mock
        transformation = Transformation(moTransformation: mockTransformationEntity)
        sut = DetailsTransformationViewModel(transformation: transformation)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias después de cada test
        sut = nil
        transformation = nil
        try super.tearDownWithError()
    }
    
    /// Test que verifica que el nombre de la transformación es correcto
    func test_GetTransformationName_ReturnsCorrectName() {
        // When: Obtenemos el nombre de la transformación desde el ViewModel
        let name = sut.getTransformationName()
        
        // Then: Verificamos que el nombre sea el esperado
        XCTAssertEqual(name, transformation.name, "El nombre de la transformación debería ser \(transformation.name)")
    }
    
    /// Test que verifica que la descripción de la transformación es correcta
    func test_GetTransformationDescription_ReturnsCorrectDescription() {
        // When: Obtenemos la descripción de la transformación desde el ViewModel
        let description = sut.getTransformationDescription()
        
        // Then: Verificamos que la descripción sea la esperada
        XCTAssertEqual(description, transformation.description, "La descripción de la transformación debería ser \(transformation.description)")
    }
    
    /// Test que verifica que la URL de la foto es válida y coincide con los datos de la transformación
    func test_GetTransformationPhotoURL_ReturnsValidURL() {
        // When: Obtenemos la URL de la foto de la transformación desde el ViewModel
        let photoURL = sut.getTransformationPhotoURL()
        
        // Then: Verificamos que la URL no sea nil y que coincida con la URL esperada
        XCTAssertNotNil(photoURL, "La URL de la foto no debería ser nil")
        XCTAssertEqual(photoURL?.absoluteString, transformation.photo, "La URL de la foto debería ser \(transformation.photo)")
    }
    
    /// Test que verifica que el ViewModel maneja correctamente una URL inválida devolviendo nil
    func test_GetTransformationPhotoURL_ReturnsNil_ForInvalidURL() {
        // Given: Creamos una transformación con una URL no válida
        let invalidTransformationEntity = MOTransformation(context: mockManagedObjectContext)
        invalidTransformationEntity.id = "trans1"
        invalidTransformationEntity.name = "Invalid Transformation"
        invalidTransformationEntity.photo = nil // URL no válida
        invalidTransformationEntity.info = "This should not work"
        
        // Inicializamos el ViewModel con la transformación inválida
        transformation = Transformation(moTransformation: invalidTransformationEntity)
        sut = DetailsTransformationViewModel(transformation: transformation)
        
        // When: Obtenemos la URL de la foto de la transformación desde el ViewModel
        let photoURL = sut.getTransformationPhotoURL()
        
        // Then: Verificamos que la URL sea nil, ya que no es válida
        XCTAssertNil(photoURL, "La URL de la foto debería ser nil para una URL inválida")
    }
}
