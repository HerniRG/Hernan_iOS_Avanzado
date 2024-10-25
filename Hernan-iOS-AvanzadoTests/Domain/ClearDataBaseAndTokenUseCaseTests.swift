//
//  ClearDatabaseAndTokenUseCaseTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// MARK: - Mock de StoreDataProvider con error simulado
// MARK: - Mock de StoreDataProvider con error simulado
class StoreDataProviderMockWithError: StoreDataProvider {
    var shouldFailClearBBDD = false // Definir la propiedad en esta clase directamente

    override func clearBBDD() throws {
        if shouldFailClearBBDD {
            // Simular un error lanzando una excepción
            throw GAError.coreDataError(error: NSError(domain: "CoreDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error cleaning database"]))
        } else {
            try super.clearBBDD()
        }
    }
}


final class ClearDatabaseAndTokenUseCaseTests: XCTestCase {
    
    var sut: ClearDatabaseAndTokenUseCase!
    var storeDataProvider: StoreDataProviderMockWithError!
    var secureDataStore: SecureDataStorageMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDataProvider = StoreDataProviderMockWithError(persistency: .inMemory)
        secureDataStore = SecureDataStorageMock()
        sut = ClearDatabaseAndTokenUseCase(storeDataProvider: storeDataProvider, secureDataStore: secureDataStore)
    }
    
    override func tearDownWithError() throws {
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
                let heroes = self.storeDataProvider.fetchHeroes(filter: nil)
                XCTAssertTrue(heroes.isEmpty, "La base de datos debería estar vacía")
                XCTAssertNil(self.secureDataStore.getToken(), "El token debería haber sido eliminado")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Se esperaba éxito, pero se recibió error: \(error.description)")
            }
        }
        
        // Esperamos la ejecución con timeout
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que se devuelve un error si ocurre un fallo al limpiar la base de datos
    func test_ClearDatabaseAndToken_ShouldFail_WhenClearingDatabaseFails() {
        // Given: Simulamos un error en el método clearBBDD del StoreDataProvider
        let expectation = expectation(description: "Clear database should fail")
        
        // Configuramos el mock para que falle al limpiar la base de datos
        storeDataProvider.shouldFailClearBBDD = true

        // Añadimos héroes a la base de datos y establecemos un token
        let apiHero = ApiHero(id: "hero1", name: "Goku", description: "Fighter", photo: "goku.jpg", favorite: true)
        storeDataProvider.add(heroes: [apiHero])
        secureDataStore.setToken("testToken")

        // When: Se llama al método clearDatabaseAndToken
        sut.clearDatabaseAndToken { result in
            switch result {
            case .success:
                XCTFail("Se esperaba error, pero se recibió éxito")
            case .failure:
                // Verificamos que el token no se haya eliminado
                XCTAssertNotNil(self.secureDataStore.getToken(), "El token no debería haberse eliminado")
                // Verificamos que la base de datos no esté vacía
                let heroes = self.storeDataProvider.fetchHeroes(filter: nil)
                XCTAssertFalse(heroes.isEmpty, "La base de datos no debería estar vacía")
                expectation.fulfill()
            }
        }

        // Esperamos la ejecución con timeout
        wait(for: [expectation], timeout: 1)
    }

}
