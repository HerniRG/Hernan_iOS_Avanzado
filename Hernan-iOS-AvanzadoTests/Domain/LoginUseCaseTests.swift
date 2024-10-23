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
        // Configuración inicial de los mocks de ApiProvider y SecureDataStore
        try super.setUpWithError()
        apiProvider = ApiProviderMock()
        secureDataStore = SecureDataStorageMock()
        sut = LoginUseCase(apiProvider: apiProvider, secureDataStore: secureDataStore)
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias después de cada test
        sut = nil
        apiProvider = nil
        secureDataStore = nil
        try super.tearDownWithError()
    }
    
    /// Test que valida que el login tiene éxito cuando las credenciales son válidas
    func test_Login_ShouldSucceed_WhenCredentialsAreValid() {
        // Given: Se configuran credenciales válidas
        let username = "validUser"
        let password = "validPassword"
        let expectation = expectation(description: "Login successful")
        
        // When: Llamamos al método login del UseCase
        sut.login(username: username, password: password) { result in
            switch result {
            case .success:
                // Then: Verificamos que el token se ha guardado correctamente
                XCTAssertNotNil(self.secureDataStore.getToken(), "El token debería haberse guardado correctamente")
                expectation.fulfill() // Indicamos que la operación ha terminado
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.description)")
            }
        }
        
        // Esperamos a que la operación se complete
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que el login falla cuando las credenciales son inválidas
    func test_Login_ShouldFail_WhenCredentialsAreInvalid() {
        // Given: Configuramos un ApiProvider que simula un error en la autenticación
        let expectation = expectation(description: "Login failed due to invalid credentials")
        sut = LoginUseCase(apiProvider: ApiProviderErrorMock(), secureDataStore: secureDataStore)
        
        // When: Llamamos al método login del UseCase con credenciales inválidas
        sut.login(username: "invalidUser", password: "invalidPassword") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Verificamos que el error recibido sea el esperado
                XCTAssertEqual(error.description, "Authentication failed. Please check your credentials")
                expectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // Esperamos a que la operación se complete
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que valida que el login falla cuando el nombre de usuario o la contraseña están vacíos
    func test_Login_ShouldFail_WhenUsernameOrPasswordIsEmpty() {
        // Given: Simulación de intentos de login con nombre de usuario o contraseña vacíos
        
        // When: Se llama a login con un nombre de usuario vacío
        let emptyUsernameExpectation = expectation(description: "Login failed due to empty username")
        sut.login(username: "", password: "validPassword") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Verificamos que el mensaje de error sea el correcto
                XCTAssertEqual(error.description, "There was an error parsing data")
                emptyUsernameExpectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // Esperamos a que la operación se complete
        wait(for: [emptyUsernameExpectation], timeout: 1)
        
        // When: Se llama a login con una contraseña vacía
        let emptyPasswordExpectation = expectation(description: "Login failed due to empty password")
        sut.login(username: "validUser", password: "") { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure(let error):
                // Then: Verificamos que el mensaje de error sea el correcto
                XCTAssertEqual(error.description, "There was an error parsing data")
                emptyPasswordExpectation.fulfill() // Indicamos que la operación ha terminado
            }
        }
        
        // Esperamos a que la operación se complete
        wait(for: [emptyPasswordExpectation], timeout: 1)
    }
}
