//
//  LoginViewModelTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// Mock del caso de uso de login para simular el comportamiento exitoso y fallido
class LoginUseCaseMock: LoginUseCaseProtocol {
    var shouldReturnError = false
    
    func login(username: String, password: String, completion: @escaping (Result<Void, GAError>) -> Void) {
        if shouldReturnError {
            completion(.failure(.errorParsingData))
        } else {
            completion(.success(()))
        }
    }
}

final class LoginViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    var loginUseCaseMock: LoginUseCaseMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        loginUseCaseMock = LoginUseCaseMock()
        sut = LoginViewModel(loginUseCase: loginUseCaseMock)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        loginUseCaseMock = nil
        try super.tearDownWithError()
    }
    
    // Test para verificar que el login devuelve success correctamente
    func testLogin_Should_Return_Success() {
        // Given
        var isSuccess = false
        let expectation = expectation(description: "Login should return success")
        
        sut.statusLogin.bind { status in
            if status == .success {
                isSuccess = true
                expectation.fulfill()
            }
        }
        
        // When
        sut.login(username: "test@example.com", password: "123456")
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(isSuccess)
    }
    
    
    // Test para verificar que el login devuelve un error correctamente
    func testLogin_Should_Return_Error() {
        // Given
        loginUseCaseMock.shouldReturnError = true
        var errorMessage: String?
        let expectation = expectation(description: "Login should return error")
        
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill()
            }
        }
        
        // When
        sut.login(username: "test@example.com", password: "123456")
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, "Fallo al iniciar sesión")
    }
    
    
    // Test para verificar que muestra error si el email está vacío
    func testLogin_Should_Return_EmptyUsernameError() {
        // Given
        var errorMessage: String?
        let expectation = expectation(description: "Login should return empty username error")
        
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill()
            }
        }
        
        // When
        sut.login(username: "", password: "123456")
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, LoginError.emptyUsername.rawValue)
    }
    
    // Test para verificar que muestra error si la contraseña está vacía
    func testLogin_Should_Return_EmptyPasswordError() {
        // Given
        var errorMessage: String?
        let expectation = expectation(description: "Login should return empty password error")
        
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill()
            }
        }
        
        // When
        sut.login(username: "test@example.com", password: "")
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, LoginError.emptyPassword.rawValue)
    }
    
    // Test para verificar el estado de loading
    func testLogin_Should_SetStatusLoading() {
        // Given
        var isLoading = false
        let expectation = expectation(description: "Set loading state")
        
        // When
        sut.statusLogin.bind { status in
            if status == .loading {
                isLoading = true
                expectation.fulfill()
            }
        }
        
        sut.login(username: "test@example.com", password: "123456")
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(isLoading)
    }
    
}
