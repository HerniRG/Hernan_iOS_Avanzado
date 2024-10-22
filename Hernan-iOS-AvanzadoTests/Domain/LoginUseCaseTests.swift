//
//  LoginUseCaseTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest

@testable import Hernan_iOS_Avanzado

final class LoginUseCaseTests: XCTestCase {
    
    var sut: LoginUseCase!
    var apiProvider: ApiProviderProtocol!
    var secureDataStore: SecureDataStoreProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        apiProvider = ApiProviderMock()
        secureDataStore = SecureDataStorageMock()
        sut = LoginUseCase(apiProvider: apiProvider, secureDataStore: secureDataStore)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        apiProvider = nil
        secureDataStore = nil
        try super.tearDownWithError()
    }
    
    func test_Login_ShouldSucceed_WhenCredentialsAreValid() {
        // Given
        let username = "validUser"
        let password = "validPassword"
        let expectation = expectation(description: "Login successful")
        
        // When
        sut.login(username: username, password: password) { result in
            switch result {
            case .success:
                // Then
                XCTAssertNotNil(self.secureDataStore.getToken()) // Verifica que el token se haya guardado
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.description)")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_Login_ShouldFail_WhenCredentialsAreInvalid() {
        // Given
        let expectation = expectation(description: "Login failed due to invalid credentials")
        
        // Mockear la respuesta de la API para fallar
        sut = LoginUseCase(apiProvider: ApiProviderErrorMock(), secureDataStore: secureDataStore)
        
        // When
        sut.login(username: "invalidUser", password: "invalidPassword") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then
                XCTAssertEqual(error.description, "Authentication failed. Please check your credentials") // Ajusta el mensaje según tu implementación
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_Login_ShouldFail_WhenUsernameOrPasswordIsEmpty() {
        // Given

        // When with empty username
        let emptyUsernameExpectation = expectation(description: "Login failed due to empty username")
        sut.login(username: "", password: "validPassword") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then
                XCTAssertEqual(error.description, "There was an error parsing data") // Ajusta el mensaje según tu implementación
                emptyUsernameExpectation.fulfill()
            }
        }

        wait(for: [emptyUsernameExpectation], timeout: 1)
        
        // When with empty password
        let emptyPasswordExpectation = expectation(description: "Login failed due to empty password")
        sut.login(username: "validUser", password: "") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then
                XCTAssertEqual(error.description, "There was an error parsing data") // Ajusta el mensaje según tu implementación
                emptyPasswordExpectation.fulfill()
            }
        }

        wait(for: [emptyPasswordExpectation], timeout: 1)
    }

}
