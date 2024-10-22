//
//  URLProtocolMock.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import Foundation

/// Mock de URLPRotocol para usar en la URLSession  de los tests de la api
/// Nos permite testar todo el código de la app, solo es fake la salida y respusta del servicio
/// WWDC 18 video reference  https://developer.apple.com/videos/play/wwdc2018/417
class URLProtocolMock: URLProtocol {
    // Errro que queremos testar
    static var error: Error?
    //Handler para uan request recibida indicamos el DATA y HTTPREsponse de respuesta para los tests
    static var handler: ((URLRequest) throws -> (Data, HTTPURLResponse))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Si hay Error se devuelve
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        // Si no hay ni error ni Handler se lanza uan excepción, uno de las 2 variables debe tener valor
        guard let handler = Self.handler else {
            fatalError("No Error or handler provided")
        }
        
        do {
            // Enviamos a al petición de la pi DAta y response  del Handler
            let (data, response) = try handler(self.request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
