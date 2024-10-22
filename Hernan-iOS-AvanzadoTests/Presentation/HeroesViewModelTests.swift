//
//  HeroesViewModelTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

class HeroUseCaseMock: HeroUseCaseProtocol {
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        let heroes = try? MockData.mockHeroes().map({$0.mapToHero()})
        completion(.success(heroes ?? []))
    }
}

class HeroUseCaseErrorMock: HeroUseCaseProtocol {
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        completion(.failure(.noDataReceived))
    }
}

final class HeroesViewModelTests: XCTestCase {
    
    var sut: HeroesViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = HeroesViewModel(useCase: HeroUseCaseMock())
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // Test para verificar que la carga de héroes devuelve datos correctamente
    func testLoad_Should_Return_Heroes() {
        //Given
        var heroes: [Hero]?
        let expectedCountHeroes = 26
        
        // When
        let expectation = expectation(description: "Load heroes")
        sut.statusHero.bind {[weak self] status in
            switch status {
            case .dataUpdated:
                heroes = self?.sut.heroes
                expectation.fulfill()
            case .error(msg: _):
                XCTFail("Expected success")
            case .none, .clearDataSuccess, .loading:
                break
            }
        }
        sut.loadData(filter: nil)
        
        //Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(heroes?.count, expectedCountHeroes)
    }
    
    
    // Test para verificar que la carga de héroes devuelve un error correctamente
    func testLoad_Should_Return_Error() {
        //Given
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
        
        //Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(msgError, "No data received from server")
    }
    
    
    // Test para verificar que el héroe en el índice dado es correcto
    func test_HeroATIndex() {
        //Given
        var hero: Hero?
        
        // When
        let expectation = expectation(description: "Load hero at index")
        sut.statusHero.bind { status in
            switch status {
            case .dataUpdated:
                expectation.fulfill()
            case .error(msg: _):
                XCTFail("Expected success")
            case .none, .clearDataSuccess, .loading:
                break
            }
        }
        sut.loadData(filter: nil)
        
        //Then
        wait(for: [expectation], timeout: 1)
        
        // Verificación del héroe en el índice 0
        hero = sut.heroAt(index: 0)
        XCTAssertNotNil(hero)
        XCTAssertEqual(hero?.name, "Androide 17")
        
        // Verificación del caso fuera de límites
        hero = sut.heroAt(index: 30)
        XCTAssertNil(hero)
    }
    
    // Test para verificar el estado de loading
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
        
        //Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(loadingState)
    }
    
    // Test para verificar que clearData devuelve success correctamente
    func testClearData_Should_Return_ClearDataSuccess() {
        //Given
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
        
        //Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(clearDataSuccess)
    }
}

// Mock para simular el comportamiento exitoso de clearData
class ClearDataUseCaseSuccessMock: ClearDatabaseAndTokenUseCaseProtocol {
    func clearDatabaseAndToken(completion: @escaping (Result<Void, GAError>) -> Void) {
        completion(.success(()))
    }
}

extension ApiHero {
    func mapToHero() -> Hero {
        return Hero(apiHero: self)
    }
}
