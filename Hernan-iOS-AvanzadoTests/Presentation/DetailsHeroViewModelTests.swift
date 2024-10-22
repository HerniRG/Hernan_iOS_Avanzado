//
//  DetailsHeroViewModelTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// MARK: - Mock de DetailsHeroUseCase
class DetailsHeroUseCaseMock: DetailsHeroUseCaseProtocol {
    var shouldReturnError = false
    let location = MOLocation()
    let transformation = MOTransformation()
    
    func loadLocationsForHeroWithId(id: String, completion: @escaping (Result<[Location], GAError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.errorFromApi(statusCode: 404)))
        } else {
            // Retorna ubicaciones de prueba
            let location = Location(moLocation: location)
            completion(.success([location]))
        }
    }
    
    func loadTransformationsForHeroWithId(id: String, completion: @escaping (Result<[Transformation], GAError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.errorFromApi(statusCode: 404)))
        } else {
            // Retorna transformaciones de prueba
            let transformation = Transformation(moTransformation: transformation)
            completion(.success([transformation]))
        }
    }
}

final class DetailsHeroViewModelTests: XCTestCase {
    
    var sut: DetailsHeroViewModel!
    var useCaseMock: DetailsHeroUseCaseMock!
    let hero = MOHero.init(entity: .init() , insertInto: nil)
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let hero = Hero(moHero: hero)
        useCaseMock = DetailsHeroUseCaseMock()
        sut = DetailsHeroViewModel(hero: hero, useCase: useCaseMock)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        useCaseMock = nil
        try super.tearDownWithError()
    }
    
    func test_LoadData_ShouldSucceed_WhenDataIsLoaded() {
        // When
        sut.loadData()
        
        // Then: Verificar que el estado es success
        XCTAssertEqual(sut.status.value, .success)
        XCTAssertFalse(sut.annotations.isEmpty, "Las anotaciones deberían haberse actualizado.")
        XCTAssertEqual(sut.transformations.count, 1, "Debería haber una transformación cargada.")
    }
    
    func test_LoadData_ShouldFail_WhenLoadingLocationsFails() {
        // Given: Indicar que debe retornar un error
        useCaseMock.shouldReturnError = true
        
        // When
        sut.loadData()
        
        // Then: Verificar que el estado es error
        XCTAssertEqual(sut.status.value, .error(msg: "Error 404"))
    }
    
    func test_LoadData_ShouldFail_WhenLoadingTransformationsFails() {
        // Given: Indicar que debe retornar un error
        useCaseMock.shouldReturnError = true
        
        // When
        sut.loadData()
        
        // Then: Verificar que el estado es error
        XCTAssertEqual(sut.status.value, .error(msg: "Error 404"))
    }
}
