//
//  DetailsHeroViewModelTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado
import CoreData

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
        try super.setUpWithError()
        
        // Asegúrate de que `hero` tiene un contexto válido
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
        sut = nil
        useCaseMock = nil
        hero = nil
        try super.tearDownWithError()
    }
    
    func test_LoadData_ShouldSucceed_WhenDataIsLoaded() {
        // When
        let expectation = self.expectation(description: "Load data")
        
        sut.loadData()
        
        // Simulamos un pequeño retraso para permitir que las cargas asíncronas se completen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then: Verificar que el estado es success
            XCTAssertEqual(self.sut.status.value, .success)
            XCTAssertFalse(self.sut.annotations.isEmpty, "Las anotaciones deberían haberse actualizado.")
            XCTAssertEqual(self.sut.transformations.count, 1, "Debería haber una transformación cargada.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    func test_LoadData_ShouldFail_WhenLoadingLocationsFails() {
        // Given: Indicar que debe retornar un error
        useCaseMock.shouldReturnError = true
        
        // When
        let expectation = self.expectation(description: "Loading locations should fail")
        
        sut.loadData()
        
        // Simulamos un pequeño retraso para permitir que las cargas asíncronas se completen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then: Verificar que el estado es error
            XCTAssertEqual(self.sut.status.value, .error(msg: "Received error from API status code 404"))
            expectation.fulfill() // Marca la expectativa como cumplida
        }
        
        wait(for: [expectation], timeout: 1) // Espera a que se cumpla la expectativa
    }
    
    func test_LoadData_ShouldFail_WhenLoadingTransformationsFails() {
            // Given: Indicar que debe retornar un error
            useCaseMock.shouldReturnError = true
            
            // When
            let expectation = self.expectation(description: "Loading transformations should fail")
            
            sut.loadData()
            
            // Simulamos un pequeño retraso para permitir que las cargas asíncronas se completen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then: Verificar que el estado es error
                XCTAssertEqual(self.sut.status.value, .error(msg: "Received error from API status code 404"))
                expectation.fulfill() // Marca la expectativa como cumplida
            }

            wait(for: [expectation], timeout: 1) // Espera a que se cumpla la expectativa
        }
}
