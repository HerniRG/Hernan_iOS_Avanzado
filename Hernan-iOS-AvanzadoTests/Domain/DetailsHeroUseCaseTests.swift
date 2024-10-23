//
//  DetailsHeroUseCaseTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

final class DetailsHeroUseCaseTests: XCTestCase {
    
    var sut: DetailsHeroUseCase!
    var apiProvider: ApiProviderProtocol!
    var storeDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        // Configuración inicial de mocks para apiProvider y storeDataProvider
        try super.setUpWithError()
        apiProvider = ApiProviderMock() // Reemplazamos con el mock necesario
        storeDataProvider = StoreDataProvider(persistency: .inMemory)
        sut = DetailsHeroUseCase(apiProvider: apiProvider, storeDataProvider: storeDataProvider)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de instancias utilizadas en los tests
        sut = nil
        apiProvider = nil
        storeDataProvider = nil
        try super.tearDownWithError()
    }
    
    /// Test que valida que se cargan ubicaciones cuando el héroe se encuentra
    func test_LoadLocations_ShouldReturnLocations_WhenHeroFound() {
        // Given
        let apiHero = ApiHero(id: "hero1", name: "Goku", description: "Fighter", photo: "goku.jpg", favorite: true)
        let apiLocation = ApiLocation(id: "loc1", date: "2024-10-20", latitude: "35.6895", longitude: "139.6917", hero: apiHero)
        
        // Agregamos un héroe al store local
        storeDataProvider.add(heroes: [apiHero])
        
        let firstExpectation = expectation(description: "Load locations for hero - First Call")
        let secondExpectation = expectation(description: "Load locations for hero - After API Call")
        
        // When: Primera llamada para cargar ubicaciones
        sut.loadLocationsForHeroWithId(id: "hero1") { result in
            switch result {
            case .success(let locations):
                // Then: Validamos que inicialmente no haya ubicaciones
                XCTAssertEqual(locations.count, 0, "Se espera que no haya ubicaciones en la base de datos todavía")
                firstExpectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }
        
        wait(for: [firstExpectation], timeout: 1)
        
        // Simulamos que se cargan las ubicaciones desde la API y las agregamos a la base de datos
        apiProvider.loadLocations(id: "hero1") { _ in
            self.storeDataProvider.add(locations: [apiLocation]) // Agregamos la ubicación a la base de datos
        }
        
        // When: Segunda llamada para cargar ubicaciones
        sut.loadLocationsForHeroWithId(id: "hero1") { result in
            switch result {
            case .success(let locations):
                // Then: Validamos que la ubicación se ha agregado correctamente
                XCTAssertEqual(locations.count, 1)
                XCTAssertEqual(locations.first?.id, apiLocation.id)
                XCTAssertEqual(locations.first?.latitude, apiLocation.latitude)
                secondExpectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }
        
        wait(for: [secondExpectation], timeout: 1)
    }
    
    /// Test que valida el comportamiento cuando no se encuentra el héroe
    func test_LoadLocations_ShouldFail_WhenHeroNotFound() {
        // Given
        let expectation = expectation(description: "Load locations should fail when hero not found")
        
        // When: Intentamos cargar ubicaciones de un héroe inexistente
        sut.loadLocationsForHeroWithId(id: "nonexistentHero") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Validamos que se devuelve el error esperado
                XCTAssertEqual(error.description, "Hero with id nonexistentHero not found")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que se cargan las transformaciones cuando el héroe se encuentra
    func test_LoadTransformations_ShouldReturnTransformations_WhenHeroFound() {
        // Given
        let apiHero = ApiHero(id: "hero1", name: "Goku", description: "Fighter", photo: "goku.jpg", favorite: true)
        let apiTransformation = ApiTransformation(id: "trans1", name: "Super Saiyan", photo: "ssj.jpg", description: "Increases power", hero: apiHero)
        
        // Agregamos un héroe al store local
        storeDataProvider.add(heroes: [apiHero])
        
        let firstExpectation = expectation(description: "Load transformations for hero - First Call")
        let secondExpectation = expectation(description: "Load transformations for hero - After API Call")
        
        // When: Primera llamada para cargar transformaciones
        sut.loadTransformationsForHeroWithId(id: "hero1") { result in
            switch result {
            case .success(let transformations):
                // Then: Validamos que inicialmente no haya transformaciones
                XCTAssertEqual(transformations.count, 0, "Se espera que no haya transformaciones en la base de datos todavía")
                firstExpectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }
        
        wait(for: [firstExpectation], timeout: 1)
        
        // Simulamos que se cargan las transformaciones desde la API y las agregamos a la base de datos
        apiProvider.loadTransformations(id: "hero1") { _ in
            self.storeDataProvider.add(transformations: [apiTransformation]) // Agregamos la transformación a la base de datos
        }
        
        // When: Segunda llamada para cargar transformaciones
        sut.loadTransformationsForHeroWithId(id: "hero1") { result in
            switch result {
            case .success(let transformations):
                // Then: Validamos que la transformación se ha agregado correctamente
                XCTAssertEqual(transformations.count, 1)
                XCTAssertEqual(transformations.first?.id, apiTransformation.id)
                secondExpectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }
        
        wait(for: [secondExpectation], timeout: 1)
    }
    
    /// Test que valida el comportamiento cuando no se encuentra el héroe al intentar cargar transformaciones
    func test_LoadTransformations_ShouldFail_WhenHeroNotFound() {
        // Given
        let expectation = expectation(description: "Load transformations should fail when hero not found")
        
        // When: Intentamos cargar transformaciones de un héroe inexistente
        sut.loadTransformationsForHeroWithId(id: "nonexistentHero") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Validamos que se devuelve el error esperado
                XCTAssertEqual(error.description, "Hero with id nonexistentHero not found")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
