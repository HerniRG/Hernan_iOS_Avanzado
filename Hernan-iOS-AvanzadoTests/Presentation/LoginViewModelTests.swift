//
//  LoginViewModelTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

// Mock del caso de uso de login para simular comportamientos exitosos y fallidos
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
        // Configuración inicial: se crea el mock del caso de uso y el ViewModel
        try super.setUpWithError()
        loginUseCaseMock = LoginUseCaseMock()
        sut = LoginViewModel(loginUseCase: loginUseCaseMock)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias después de cada test
        sut = nil
        loginUseCaseMock = nil
        try super.tearDownWithError()
    }
    
    /// Test que verifica que el login devuelve success correctamente
    func testLogin_Should_Return_Success() {
        // Given: Preparamos la variable para verificar el estado de éxito
        var isSuccess = false
        let expectation = expectation(description: "Login should return success")
        
        // Vinculamos el estado del login con el ViewModel
        sut.statusLogin.bind { status in
            if status == .success {
                isSuccess = true
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // When: Llamamos al método login del ViewModel
        sut.login(username: "test@example.com", password: "123456")
        
        // Then: Verificamos que el login tuvo éxito
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(isSuccess)
    }
    
    /// Test que verifica que el login devuelve un error correctamente
    func testLogin_Should_Return_Error() {
        // Given: Configuramos el mock para devolver un error
        loginUseCaseMock.shouldReturnError = true
        var errorMessage: String?
        let expectation = expectation(description: "Login should return error")
        
        // Vinculamos el estado del login con el ViewModel
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // When: Llamamos al método login del ViewModel
        sut.login(username: "test@example.com", password: "123456")
        
        // Then: Verificamos que se recibió el mensaje de error esperado
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, "Fallo al iniciar sesión")
    }
    
    /// Test que verifica que muestra un error si el nombre de usuario está vacío
    func testLogin_Should_Return_EmptyUsernameError() {
        // Given: Preparamos la variable para verificar el mensaje de error
        var errorMessage: String?
        let expectation = expectation(description: "Login should return empty username error")
        
        // Vinculamos el estado del login con el ViewModel
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // When: Llamamos al método login del ViewModel con un nombre de usuario vacío
        sut.login(username: "", password: "123456")
        
        // Then: Verificamos que se recibió el mensaje de error esperado
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, LoginError.emptyUsername.rawValue)
    }
    
    /// Test que verifica que muestra un error si la contraseña está vacía
    func testLogin_Should_Return_EmptyPasswordError() {
        // Given: Preparamos la variable para verificar el mensaje de error
        var errorMessage: String?
        let expectation = expectation(description: "Login should return empty password error")
        
        // Vinculamos el estado del login con el ViewModel
        sut.statusLogin.bind { status in
            if case .error(let msg) = status {
                errorMessage = msg
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // When: Llamamos al método login del ViewModel con una contraseña vacía
        sut.login(username: "test@example.com", password: "")
        
        // Then: Verificamos que se recibió el mensaje de error esperado
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorMessage, LoginError.emptyPassword.rawValue)
    }
    
    /// Test que verifica que el estado de loading se establece correctamente
    func testLogin_Should_SetStatusLoading() {
        // Given: Preparamos la variable para verificar el estado de loading
        var isLoading = false
        let expectation = expectation(description: "Set loading state")
        
        // Vinculamos el estado del login con el ViewModel
        sut.statusLogin.bind { status in
            if status == .loading {
                isLoading = true
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // When: Llamamos al método login del ViewModel
        sut.login(username: "test@example.com", password: "123456")
        
        // Then: Verificamos que el estado de loading se haya activado
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(isLoading)
    }
}
