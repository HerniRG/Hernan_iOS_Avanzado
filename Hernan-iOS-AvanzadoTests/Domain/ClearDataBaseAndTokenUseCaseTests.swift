//
//  ClearDatabaseAndTokenUseCaseTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// MARK: - Mock de StoreDataProvider
class StoreDataProviderMockWithError: StoreDataProvider {
    override func clearBBDD() throws {
        throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error cleaning database"])
    }
}


final class ClearDatabaseAndTokenUseCaseTests: XCTestCase {

    var sut: ClearDatabaseAndTokenUseCase!
    var storeDataProvider: StoreDataProvider!
    var secureDataStore: SecureDataStorageMock! // Usar tu mock aquí

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDataProvider = StoreDataProvider(persistency: .inMemory)
        secureDataStore = SecureDataStorageMock() // Inicializar el mock
        sut = ClearDatabaseAndTokenUseCase(storeDataProvider: storeDataProvider, secureDataStore: secureDataStore)
    }

    override func tearDownWithError() throws {
        sut = nil
        storeDataProvider = nil
        secureDataStore = nil
        try super.tearDownWithError()
    }

    func test_ClearDatabaseAndToken_ShouldSucceed_WhenCalled() {
        // Given: Agregar héroes y un token
        let apiHero = ApiHero(id: "hero1", name: "Goku", description: "Fighter", photo: "goku.jpg", favorite: true)
        storeDataProvider.add(heroes: [apiHero])
        secureDataStore.setToken("testToken")

        let expectation = expectation(description: "Clear database and token")

        // When: Llamar a clearDatabaseAndToken
        sut.clearDatabaseAndToken { result in
            switch result {
            case .success:
                // Then: Verificar que la base de datos esté vacía y el token eliminado
                XCTAssertTrue(self.storeDataProvider.fetchHeroes(filter: nil).isEmpty, "La base de datos debería estar vacía")
                XCTAssertNil(self.secureDataStore.getToken(), "El token debería haber sido eliminado")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got error")
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_ClearDatabaseAndToken_ShouldFail_WhenClearingDatabaseFails() {
        // Given: Mockear el StoreDataProvider para lanzar un error
        let expectation = expectation(description: "Clear database should fail")

        storeDataProvider = StoreDataProviderMockWithError() // Mock que simula error en clearBBDD
        sut = ClearDatabaseAndTokenUseCase(storeDataProvider: storeDataProvider, secureDataStore: secureDataStore)

        // When: Llamar a clearDatabaseAndToken
        sut.clearDatabaseAndToken { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Verificar que se devuelve el error esperado
                XCTAssertEqual(error.description, "Core Data error: Error cleaning database")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }
}
