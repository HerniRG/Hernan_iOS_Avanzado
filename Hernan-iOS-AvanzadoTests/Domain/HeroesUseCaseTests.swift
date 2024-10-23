//
//  HeroesUseCaseTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

final class HeroesUseCaseTests: XCTestCase {
    
    var sut: HeroUseCase!
    var storeDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        // Configuración inicial: se usa un StoreDataProvider en memoria y un ApiProvider mockeado
        try super.setUpWithError()
        storeDataProvider = StoreDataProvider(persistency: .inMemory)
        sut = HeroUseCase(apiProvider: ApiProviderMock(), storeDataProvider: storeDataProvider)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias después de cada test
        storeDataProvider = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Test que valida que se cargan los héroes correctamente desde la API
    func test_LoadHeroes_ShouldReturnHeroes() {
        // Given: Se preparan los datos de héroes esperados
        let expectedHeroes = try? MockData.mockHeroes()
        var receivedHeroes: [Hero]?
        
        // When: Llamamos al método loadHeros del UseCase
        let expectation = expectation(description: "Load heroes")
        sut.loadHeros { result in
            switch result {
            case .success(let heroes):
                receivedHeroes = heroes
                expectation.fulfill() // Indicamos que la operación ha terminado
            case .failure(_):
                XCTFail("Expected success")
            }
        }
        
        // Then: Validamos que los héroes cargados coinciden con los esperados
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(receivedHeroes)
        XCTAssertEqual(receivedHeroes?.count, expectedHeroes?.count)
        
        // Verificamos que los héroes también se guardan en la base de datos
        let bdHeroes = storeDataProvider.fetchHeroes(filter: nil)
        XCTAssertEqual(receivedHeroes?.count, bdHeroes.count)
    }
    
    /// Test que valida que se devuelve un error si la carga de héroes falla
    func test_LoadHeroes_Error_ShouldReturnError() {
        // Given: Se utiliza un ApiProvider mock que simula un error
        sut = HeroUseCase(apiProvider: ApiProviderErrorMock(), storeDataProvider: storeDataProvider)
        var error: GAError?
        
        // When: Llamamos al método loadHeros del UseCase
        let expectation = expectation(description: "Load heroes return error")
        sut.loadHeros { result in
            switch result {
            case .success(_):
                XCTFail("Expected error")
            case .failure(let errorReceived):
                error = errorReceived
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // Then: Validamos que se ha recibido el error correcto
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.description, "No data received from server")
    }
    
    /// Test que valida que los héroes se guardan correctamente en la base de datos después de cargarse
    func test_LoadHeroes_ShouldSaveHeroesToDatabase() {
        // Given: Variables para almacenar los héroes recibidos
        var receivedHeroes: [Hero]?
        
        // When: Llamamos al método loadHeros del UseCase
        let expectation = expectation(description: "Load and save heroes to database")
        sut.loadHeros { result in
            switch result {
            case .success(let heroes):
                receivedHeroes = heroes
                expectation.fulfill() // Indicamos que la operación ha terminado
            case .failure(_):
                XCTFail("Expected success")
            }
        }
        
        // Then: Validamos que los héroes se han guardado correctamente en la base de datos
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(receivedHeroes)
        
        let bdHeroes = storeDataProvider.fetchHeroes(filter: nil)
        XCTAssertEqual(receivedHeroes?.count, bdHeroes.count)
    }
    
    /// Test que valida que no se llama a la API si ya existen héroes en la base de datos
    func test_LoadHeroes_ShouldNotCallAPIIfHeroesExistInDatabase() {
        // Given: Se añaden héroes a la base de datos para simular que ya existen
        let mockHeroes = try? MockData.mockHeroes()
        storeDataProvider.add(heroes: mockHeroes ?? [])
        var receivedHeroes: [Hero]?
        
        // When: Llamamos al método loadHeros del UseCase
        let expectation = expectation(description: "Do not call API if heroes exist in database")
        sut.loadHeros { result in
            switch result {
            case .success(let heroes):
                receivedHeroes = heroes
                expectation.fulfill() // Indicamos que la operación ha terminado
            case .failure(_):
                XCTFail("Expected success")
            }
        }
        
        // Then: Validamos que los héroes se cargan desde la base de datos, no desde la API
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(receivedHeroes)
        
        let bdHeroes = storeDataProvider.fetchHeroes(filter: nil)
        XCTAssertEqual(receivedHeroes?.count, bdHeroes.count)
    }
}
