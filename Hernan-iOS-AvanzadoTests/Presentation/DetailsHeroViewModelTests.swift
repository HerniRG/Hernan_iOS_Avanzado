//
//  DetailsHeroViewModelTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado
import CoreData

// Mock del caso de uso para simular el comportamiento del DetailsHeroUseCase
class DetailsHeroUseCaseMock: DetailsHeroUseCaseProtocol {
    var shouldReturnError = false
    var mockLocations: [MOLocation] = []
    var mockTransformations: [MOTransformation] = []
    
    func loadLocationsForHeroWithId(id: String, completion: @escaping (Result<[Location], GAError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.errorFromApi(statusCode: 404)))
        } else {
            let location = MOLocation(context: mockManagedObjectContext)
            location.id = "loc1"
            location.latitude = "35.6895"
            location.longitude = "139.6917"
            location.date = "2024-10-20"
            
            let locationDomain = Location(moLocation: location)
            completion(.success([locationDomain]))
        }
    }
    
    func loadTransformationsForHeroWithId(id: String, completion: @escaping (Result<[Transformation], GAError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.errorFromApi(statusCode: 404)))
        } else {
            let transformation = MOTransformation(context: mockManagedObjectContext)
            transformation.id = "trans1"
            transformation.name = "Super Saiyan"
            transformation.photo = "ssj.jpg"
            transformation.info = "Increases power"
            
            let transformationDomain = Transformation(moTransformation: transformation)
            completion(.success([transformationDomain]))
        }
    }
}

// Simulando un contexto de Core Data para pruebas
var mockManagedObjectContext: NSManagedObjectContext {
    let persistentContainer = NSPersistentContainer(name: "Model")
    persistentContainer.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Error loading mock context: \(error)")
        }
    }
    return persistentContainer.viewContext
}

final class DetailsHeroViewModelTests: XCTestCase {
    
    var sut: DetailsHeroViewModel!
    var useCaseMock: DetailsHeroUseCaseMock!
    var hero: Hero!
    
    override func setUpWithError() throws {
        // Inicialización del mock de Core Data para el héroe y el caso de uso
        try super.setUpWithError()
        
        let heroEntity = MOHero(context: mockManagedObjectContext)
        heroEntity.id = "hero1"
        heroEntity.name = "Goku"
        heroEntity.info = "Fighter"
        heroEntity.photo = "goku.jpg"
        heroEntity.favorite = true
        
        hero = Hero(moHero: heroEntity)
        useCaseMock = DetailsHeroUseCaseMock()
        sut = DetailsHeroViewModel(hero: hero, useCase: useCaseMock)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias de ViewModel, UseCase y Héroe
        sut = nil
        useCaseMock = nil
        hero = nil
        try super.tearDownWithError()
    }
    
    /// Test que valida que los datos se cargan correctamente cuando no hay errores
    func test_LoadData_ShouldSucceed_WhenDataIsLoaded() {
        // When: Se llama a loadData en el ViewModel
        let expectation = self.expectation(description: "Load data")
        
        sut.loadData()
        
        // Simulamos un pequeño retraso para permitir la carga asíncrona
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then: Validamos que el estado sea success y que los datos se hayan cargado correctamente
            XCTAssertEqual(self.sut.status.value, .success)
            XCTAssertFalse(self.sut.annotations.isEmpty, "Las anotaciones deberían haberse actualizado.")
            XCTAssertEqual(self.sut.transformations.count, 1, "Debería haber una transformación cargada.")
            expectation.fulfill()
        }
        
        // Esperamos a que se cumpla la expectativa
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que el estado es error cuando la carga de ubicaciones falla
    func test_LoadData_ShouldFail_WhenLoadingLocationsFails() {
        // Given: Configuramos el mock para que devuelva un error
        useCaseMock.shouldReturnError = true
        
        // When: Se llama a loadData en el ViewModel
        let expectation = self.expectation(description: "Loading locations should fail")
        
        sut.loadData()
        
        // Simulamos un pequeño retraso para permitir la carga asíncrona
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then: Verificamos que el estado sea error con el mensaje esperado
            XCTAssertEqual(self.sut.status.value, .error(msg: "Received error from API status code 404"))
            expectation.fulfill()
        }
        
        // Esperamos a que se cumpla la expectativa
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que el estado es error cuando la carga de transformaciones falla
    func test_LoadData_ShouldFail_WhenLoadingTransformationsFails() {
        // Given: Configuramos el mock para que devuelva un error
        useCaseMock.shouldReturnError = true
        
        // When: Se llama a loadData en el ViewModel
        let expectation = self.expectation(description: "Loading transformations should fail")
        
        sut.loadData()
        
        // Simulamos un pequeño retraso para permitir la carga asíncrona
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then: Verificamos que el estado sea error con el mensaje esperado
            XCTAssertEqual(self.sut.status.value, .error(msg: "Received error from API status code 404"))
            expectation.fulfill()
        }
        
        // Esperamos a que se cumpla la expectativa
        wait(for: [expectation], timeout: 1)
    }
}
