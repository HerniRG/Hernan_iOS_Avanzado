//
//  ApiProviderTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

/// Clase para hacer testing de ApiProvider
final class ApiProviderTests: XCTestCase {
    
    var sut: ApiProvider!
    
    override func setUpWithError() throws {
        // Configuración de la URLSession con protocolo mock y request builder mock
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)
        
        // Uso del mock de SecureDataStorage para el request builder
        let requestProvider = GARequestBuilder(secureStorage: SecureDataStorageMock())
        
        // Inicialización del ApiProvider con los mocks configurados
        sut = ApiProvider(session: session, requestBuilder: requestProvider)
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        // Reseteo de objetos para evitar interferencias entre tests
        SecureDataStorageMock().deleteToken()
        URLProtocolMock.handler = nil
        URLProtocolMock.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Test para validar que se cargan 26 héroes correctamente desde la API
    func test_loadHeros_shouldReturn_26Heroes() throws {
        // Given
        let expectedToken = "Some Token"
        let expectedHero = try MockData.mockHeroes().first!
        var heroesResponse = [ApiHero]()
        
        // Configure the mock handler
        URLProtocolMock.handler = { request in
            // Validate the request
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/all"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Provide mock data
            let data = try MockData.loadHeroesData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Heroes")
        setToken(expectedToken)
        sut.loadHeros { result in
            switch result {
            case .success(let apiheroes):
                heroesResponse = apiheroes
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Success expected, but got error: \(error)")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(heroesResponse.isEmpty, "heroesResponse should not be empty")
        let heroReceived = heroesResponse.first
        XCTAssertEqual(heroesResponse.count, 26)
        XCTAssertEqual(heroReceived?.id, expectedHero.id)
        XCTAssertEqual(heroReceived?.name, expectedHero.name)
        XCTAssertEqual(heroReceived?.description, expectedHero.description)
        XCTAssertEqual(heroReceived?.favorite, expectedHero.favorite)
        XCTAssertEqual(heroReceived?.photo, expectedHero.photo)
    }
    
    
    /// Test para validar el comportamiento de error cuando la API falla
    func test_loadHerosError_shouldReturn_Error() throws {
        // Given
        let expectedToken = "Some Token"
        var error: GAError?
        
        // Simulación de un error en la llamada a la API
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 503)
        
        // When
        // Llamada al método loadHeros de la API y configuración de expectation
        let expectation = expectation(description: "Load Heroes Error")
        setToken(expectedToken)
        sut.loadHeros { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        // Validación de que el error recibido es el esperado
        wait(for: [expectation], timeout: 2)
        let receivedError = try XCTUnwrap(error)
        XCTAssertEqual(receivedError.description, "Received error from server \(503)")
    }
    
    /// Función de utilidad para configurar el token en el almacenamiento seguro
    func setToken(_ token: String) {
        SecureDataStorageMock().setToken(token)
    }
    
    /// Test para validar que se cargan las transformaciones correctamente desde la API
    func test_loadTransformations_shouldReturn_Transformations() throws {
        // Given
        let expectedToken = "Some Token"
        let expectedTransformation = try MockData.mockTransformations().first!
        var transformationsResponse = [ApiTransformation]()
        
        // Configuración del handler para simular la respuesta de la API
        URLProtocolMock.handler = { request in
            // Validación de la request generada por la app
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/tranformations"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Respuesta simulada con datos de transformaciones mock
            let data = try MockData.loadTransformationsData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Transformations")
        setToken(expectedToken)
        sut.loadTransformations(id: "1") { result in
            switch result {
            case .success(let transformations):
                transformationsResponse = transformations
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(transformationsResponse.count, 1)
        XCTAssertEqual(transformationsResponse.first?.id, expectedTransformation.id)
    }
    
    /// Test para validar el comportamiento de error cuando falla la carga de transformaciones
    func test_loadTransformationsError_shouldReturn_Error() throws {
        // Given
        let expectedToken = "Some Token"
        var error: GAError?
        
        // Simulación de un error en la llamada a la API
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 500)
        
        // When
        let expectation = expectation(description: "Load Transformations Error")
        setToken(expectedToken)
        sut.loadTransformations(id: "1") { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(error?.description, "Received error from server \(500)")
    }
    
    /// Test para validar que se cargan las ubicaciones correctamente desde la API
    func test_loadLocations_shouldReturn_Locations() throws {
        // Given
        let expectedToken = "Some Token"
        let expectedLocation = try MockData.mockLocations().first!
        var locationsResponse = [ApiLocation]()
        
        // Configuración del handler para simular la respuesta de la API
        URLProtocolMock.handler = { request in
            // Validación de la request generada por la app
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/locations"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Respuesta simulada con datos de ubicaciones mock
            let data = try MockData.loadLocationsData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Locations")
        setToken(expectedToken)
        sut.loadLocations(id: "1") { result in
            switch result {
            case .success(let locations):
                locationsResponse = locations
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(locationsResponse.count, 1)
        XCTAssertEqual(locationsResponse.first?.id, expectedLocation.id)
    }
    
    /// Test para validar el comportamiento de error cuando falla la carga de ubicaciones
    func test_loadLocationsError_shouldReturn_Error() throws {
        // Given
        let expectedToken = "Some Token"
        var error: GAError?
        
        // Simulación de un error en la llamada a la API
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 404)
        
        // When
        let expectation = expectation(description: "Load Locations Error")
        setToken(expectedToken)
        sut.loadLocations(id: "1") { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(error?.description, "Received error from server \(404)")
    }
    
    /// Test para validar el inicio de sesión exitoso
    func test_login_shouldReturn_Token() throws {
        // Given
        let username = "testuser"
        let password = "testpassword"
        let expectedToken = "SomeJWTToken"
        
        // Configuración del handler para simular la respuesta de la API
        URLProtocolMock.handler = { request in
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/auth/login"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            
            // Respuesta simulada con un token JWT
            let data = expectedToken.data(using: .utf8)!
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Login")
        var loginResponse: String?
        
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(let token):
                loginResponse = token
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(loginResponse, expectedToken)
    }
    
    /// Test para validar el fallo en el inicio de sesión (credenciales incorrectas)
    func test_login_shouldFail_With401() throws {
        // Given
        let username = "wronguser"
        let password = "wrongpassword"
        var error: GAError?
        
        // Simulación de un error de autenticación (401)
        URLProtocolMock.handler = { request in
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/login"))
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }
        
        // When
        let expectation = expectation(description: "Login Failure")
        
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(_):
                XCTFail("Failure expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(error?.description, "Authentication failed. Please check your credentials")
    }
}
