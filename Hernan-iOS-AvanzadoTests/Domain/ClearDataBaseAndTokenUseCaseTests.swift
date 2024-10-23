//
//  ClearDatabaseAndTokenUseCaseTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// MARK: - Mock de StoreDataProvider con error simulado
class StoreDataProviderMockWithError: StoreDataProvider {
    override func clearBBDD() throws {
        // Simulación de un error al intentar limpiar la base de datos
        throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error cleaning database"])
    }
}

final class ClearDatabaseAndTokenUseCaseTests: XCTestCase {
    
    var sut: ClearDatabaseAndTokenUseCase!
    var storeDataProvider: StoreDataProvider!
    var secureDataStore: SecureDataStorageMock!
    
    override func setUpWithError() throws {
        // Inicialización de StoreDataProvider y SecureDataStorage mocks
        try super.setUpWithError()
        storeDataProvider = StoreDataProvider(persistency: .inMemory)
        secureDataStore = SecureDataStorageMock()
        sut = ClearDatabaseAndTokenUseCase(storeDataProvider: storeDataProvider, secureDataStore: secureDataStore)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias creadas durante los tests
        sut = nil
        storeDataProvider = nil
        secureDataStore = nil
        try super.tearDownWithError()
    }
    
    /// Test que valida que la base de datos y el token se eliminan correctamente
    func test_ClearDatabaseAndToken_ShouldSucceed_WhenCalled() {
        // Given: Se añaden héroes a la base de datos y se almacena un token
        let apiHero = ApiHero(id: "hero1", name: "Goku", description: "Fighter", photo: "goku.jpg", favorite: true)
        storeDataProvider.add(heroes: [apiHero])
        secureDataStore.setToken("testToken")
        
        let expectation = expectation(description: "Clear database and token")
        
        // When: Se llama al método clearDatabaseAndToken
        sut.clearDatabaseAndToken { result in
            switch result {
            case .success:
                // Then: Validamos que la base de datos esté vacía y el token haya sido eliminado
                XCTAssertTrue(self.storeDataProvider.fetchHeroes(filter: nil).isEmpty, "La base de datos debería estar vacía")
                XCTAssertNil(self.secureDataStore.getToken(), "El token debería haber sido eliminado")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }
        
        // Esperamos la ejecución con timeout
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que se devuelve un error si ocurre un fallo al limpiar la base de datos
    func test_ClearDatabaseAndToken_ShouldFail_WhenClearingDatabaseFails() {
        // Given: Simulamos un error en el método clearBBDD del StoreDataProvider
        let expectation = expectation(description: "Clear database should fail")
        
        storeDataProvider = StoreDataProviderMockWithError() // Mock con error al limpiar la base de datos
        sut = ClearDatabaseAndTokenUseCase(storeDataProvider: storeDataProvider, secureDataStore: secureDataStore)
        
        // When: Se llama al método clearDatabaseAndToken
        sut.clearDatabaseAndToken { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Validamos que el error devuelto es el esperado
                XCTAssertEqual(error.description, "Core Data error: Error cleaning database")
                expectation.fulfill()
            }
        }
        
        // Esperamos la ejecución con timeout
        wait(for: [expectation], timeout: 1)
    }
}
