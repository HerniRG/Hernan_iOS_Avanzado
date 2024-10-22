//
//  APIProviderTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado


/// Clase para hacer Testing de Api PRovider
final class ApiProviderTests: XCTestCase {
    
    var sut: ApiProvider!

    override func setUpWithError() throws {
        
        // Configuramos APi Provider
        //      .Usamos ephemeral porque no usa disco para anda
        //      .Le indicamso que lso protocols será nuestro Mock
        //      .Creamso la session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)
        
        // PAra el request Provider usamos nuestro mock para SEcureDataStorage
        let requestProvider = GARequestBuilder(secureStorage: SecureDataStorageMock())
        
        // creamos ApiProvider
        sut = ApiProvider(session: session, requestBuilder: requestProvider)
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Hacemso reset de los objetos
        SecureDataStorageMock().deleteToken()
        URLProtocolMock.handler = nil
        URLProtocolMock.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_loadHeros_shouldReturn_26_Heroes() throws {
        // Given
        
        //preparamso la info que nos va a hacer falta para el test
        let expecrtedToken = "Some Token"
        let expectedHero = try MockData.mockHeroes().first!
        var heroesResponse = [ApiHero]()
        URLProtocolMock.handler = { request in
            
            // En el Handle, validamos la request, httpmethod, url, headers, lo que consideremos oportuno,
            // se podría comprobar el body pro ejemplo también. Esrta request es la que crea nuestra app
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/all"))
            
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expecrtedToken)")
            
            // Devolvemso Data y response del Handler
            let data = try MockData.loadHeroesData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            
           return  (data, response)
        }
        
        // When
        // Una vez tenemso los datos para código asuncrono creamos expectations
        // Indicando que ya ha erminado con expectation.fulfill()""
        // llamamos a nuestro método de la api y validamos que la respuesta es  la resperada
        let expectation = expectation(description: "Load Heroes")
        setToken(expecrtedToken)
        sut.loadHeros { result in
            switch result {
            case .success(let apiheroes):
                heroesResponse = apiheroes
                expectation.fulfill()
            case .failure( _):
                XCTFail("Success expected")
            }
        }
        
        //Then
        
        // Validamso los datos recibidos
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(heroesResponse.count, 26)
        let heroReceived = heroesResponse.first
        XCTAssertEqual(heroReceived?.id, expectedHero.id)
        XCTAssertEqual(heroReceived?.name, expectedHero.name)
        XCTAssertEqual(heroReceived?.description, expectedHero.description)
        XCTAssertEqual(heroReceived?.favorite, expectedHero.favorite)
        XCTAssertEqual(heroReceived?.photo, expectedHero.photo)
        
    }
    
    func test_loadHerosError_shouldReturn_Error() throws {
        // Given
        
        // para datos de error es más sencillo, le asignamos el error testar a URLprotocolMock
        let expecrtedToken = "Some Token"
        var error: GAError?
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 503)
        
        // When
        // Una vez tenemso los datos para código asuncrono creamos expectations
        // Indicando que ya ha erminado con expectation.fulfill()""
        // llamamos a nuestro método de la api y validamos que la respuesta es  la resperada
        let expectation = expectation(description: "Load Heroes Error")
        setToken(expecrtedToken)
        sut.loadHeros { result in
            switch result {
            case .success( _):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }

        //Then
        // Validamso que tenemos el error y su mensaje.
        wait(for: [expectation], timeout: 2)
        let receivedError = try XCTUnwrap(error)
        XCTAssertEqual(receivedError.description, "Received error from server \(503)")
    }
    
    func setToken(_ token: String) {
        SecureDataStorageMock().setToken(token)
    }

}
