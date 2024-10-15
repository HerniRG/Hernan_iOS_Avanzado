//
//  APIProvider.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

protocol ApiProviderProtocol {
    func loadHeros(name: String, completion: @escaping ((Result<[ApiHero], GAError>) -> Void))
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void))
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void))
}

/// Clase encargada de hacer las llamadas a la Api
class ApiProvider {
    // Sesión de red
    private let session: URLSession
    private let requestBuilder: GARequestBuilder
    
    
    /// Constructor de ApiProvider
    /// - Parameters:
    ///   - session: Session de red
    ///   - requestBuilder: builder para las requst
    init(session: URLSession = .shared, requestBuilder: GARequestBuilder = GARequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    
    /// Obtiene los héroes de la api
    /// - Parameters:
    ///   - name: "Nombre el hero a obtener "" default value para obtenerlos todos"
    ///   - completion: DEvuelve un Result con los heroes o un GAError
    func loadHeros(name: String = "", completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .heroes, params: ["name": name]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    /// Obtiene las localizaciones de la api
    /// - Parameters:
    ///   - id: Id del hero para el cual se quieren obtneer las locaclizaciones
    ///   - completion: DEvuelve un Result con las localizaciones o un GAError
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .locations, params: ["id": id]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    /// Obtiene las trnasformaciones de la api
    /// - Parameters:
    ///   - id: Id del hero para el cual se quieren obtneer las trnasformaciones
    ///   - completion: DEvuelve un Result con las trnasformaciones o un GAError
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .transformations, params: ["id": id]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    
    
    /// Método que realiza la request, usa un genérico cuya condición  es que sea decodable
    /// DE este método lo podemos usar con cualquier request  de la que se espera un resultado "Result" de un objeto "decodable o un error
    /// - Parameters:
    ///   - request: request a realizar
    ///   - completion: Completion con un Result con un dato decodable o GAError
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, GAError>) -> Void)) {
            session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.errorFromServer(error: error)))
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            if statusCode != 200 {
                completion(.failure(.errorFromApi(statusCode: statusCode ?? -1)))
                return
            }
            if let data {
                do {
                    let apiInfo = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(apiInfo))
                } catch {
                    completion(.failure(.errorParsingData))
                }
            } else {
                completion(.failure(.noDataReceived))
            }
        }.resume()
    }
}
