//
//  HeroesViewModelTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// Mock para simular el caso de uso de éxito en la carga de héroes
class HeroUseCaseMock: HeroUseCaseProtocol {
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        let heroes = try? MockData.mockHeroes().map({$0.mapToHero()})
        completion(.success(heroes ?? []))
    }
}

// Mock para simular el caso de uso que falla en la carga de héroes
class HeroUseCaseErrorMock: HeroUseCaseProtocol {
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        completion(.failure(.noDataReceived))
    }
}

// Mock para simular el comportamiento exitoso de clearData
class ClearDataUseCaseSuccessMock: ClearDatabaseAndTokenUseCaseProtocol {
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion(.success(()))
        }
    }
}


final class HeroesViewModelTests: XCTestCase {
    
    var sut: HeroesViewModel!
    
    override func setUpWithError() throws {
        // Inicialización del ViewModel con un caso de uso mockeado para el test
        try super.setUpWithError()
        sut = HeroesViewModel(useCase: HeroUseCaseMock())
    }
    
    override func tearDownWithError() throws {
        // Limpieza de la instancia del ViewModel después del test
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Test que verifica que la carga de héroes devuelve datos correctamente
    func testLoad_Should_Return_Heroes() {
        // Given
        var heroes: [Hero]?
        let expectedCountHeroes = 26
        
        // When
        let expectation = expectation(description: "Load heroes")
        sut.statusHero.bind {[weak self] status in
            switch status {
            case .dataUpdated:
                heroes = self?.sut.getHeroes()
                expectation.fulfill()
            case .error(msg: _):
                XCTFail("Expected success")
            case .none, .clearDataSuccess, .loading:
                break
            }
        }
        sut.loadData(filter: nil)
        
        // Then
        wait(for: [expectation], timeout: 2) 
        XCTAssertEqual(heroes?.count, expectedCountHeroes)
    }
    
    /// Test que verifica que la carga de héroes devuelve un error correctamente
    func testLoad_Should_Return_Error() {
        // Given
        sut = HeroesViewModel(useCase: HeroUseCaseErrorMock())
        var msgError: String?
        
        // When
        let expectation = expectation(description: "Load Heroes should return error")
        sut.statusHero.bind { status in
            switch status {
            case .dataUpdated:
                XCTFail("Expected Error")
            case .error(msg: let msg):
                msgError = msg
                expectation.fulfill()
            case .none, .clearDataSuccess, .loading:
                break
            }
        }
        sut.loadData(filter: nil)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(msgError, "No data received from server")
    }
    
    /// Test que verifica que el héroe en el índice dado es el correcto
    func test_HeroATIndex() {
        // Given
        var hero: Hero?
        var didFulfillExpectation = false  // Flag to prevent multiple fulfill calls

        // When
        let expectation = expectation(description: "Load hero at index")
        sut.statusHero.bind { status in
            switch status {
            case .dataUpdated:
                if !didFulfillExpectation {  // Verifica si ya se cumplió
                    didFulfillExpectation = true
                    expectation.fulfill()
                }
            case .error(msg: _):
                if !didFulfillExpectation {
                    XCTFail("Expected success")
                    didFulfillExpectation = true
                }
            case .none, .clearDataSuccess, .loading:
                break
            }
        }
        sut.loadData(filter: nil)

        // Then
        wait(for: [expectation], timeout: 2)

        hero = sut.heroAt(index: 0)
        XCTAssertNotNil(hero)
        XCTAssertEqual(hero?.name, "Androide 17")

        // Verificación del caso fuera de límites
        hero = sut.heroAt(index: 30)
        XCTAssertNil(hero)
    }

    /// Test que verifica el estado de loading
    func testLoad_Should_SetStatusLoading() {
        // Given
        var loadingState: Bool = false
        let expectation = expectation(description: "Set loading state")
        
        // When
        sut.statusHero.bind { status in
            if status == .loading {
                loadingState = true
                expectation.fulfill()
            }
        }
        
        sut.loadData(filter: nil)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(loadingState)
    }
    
    /// Test que verifica que clearData devuelve success correctamente
    func testClearData_Should_Return_ClearDataSuccess() {
        // Given
        sut = HeroesViewModel(useCase: HeroUseCaseMock(), clearDataUseCase: ClearDataUseCaseSuccessMock())
        var clearDataSuccess: Bool = false
        
        // When
        let expectation = expectation(description: "Clear data should return success")
        sut.statusHero.bind { status in
            switch status {
            case .clearDataSuccess:
                clearDataSuccess = true
                expectation.fulfill()
            case .none, .dataUpdated, .error(msg: _), .loading:
                break
            }
        }
        sut.clearData()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(clearDataSuccess)
    }
}
