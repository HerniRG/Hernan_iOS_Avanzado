//
//  APIProviderTests.swift
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
    func test_loadHeros_shouldReturn_26_Heroes() throws {
        // Given
        let expectedToken = "Some Token"
        let expectedHero = try MockData.mockHeroes().first!
        var heroesResponse = [ApiHero]()
        
        // Configuración del handler para mockear la respuesta de la API
        URLProtocolMock.handler = { request in
            // Validación de la request generada por la app
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/all"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Respuesta simulada con datos de héroes mock
            let data = try MockData.loadHeroesData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        // Llamada al método loadHeros de la API y configuración de expectation
        let expectation = expectation(description: "Load Heroes")
        setToken(expectedToken)
        sut.loadHeros { result in
            switch result {
            case .success(let apiheroes):
                heroesResponse = apiheroes
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        // Validación de los resultados
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(heroesResponse.count, 26)
        let heroReceived = heroesResponse.first
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
}
