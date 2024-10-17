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
    func login(username: String, password: String, completion: @escaping ((Result<ApiLogin, GAError>) -> Void))
}

class ApiProvider: ApiProviderProtocol {
    private let session: URLSession
    private let requestBuilder: GARequestBuilder
    
    init(session: URLSession = .shared, requestBuilder: GARequestBuilder = GARequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    func loadHeros(name: String = "", completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .heroes, params: ["name": name]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .locations, params: ["id": id]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        if let request = requestBuilder.buildRequest(endPoint: .transformations, params: ["id": id]) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.requestWasNil))
        }
    }
    
    func login(username: String, password: String, completion: @escaping ((Result<ApiLogin, GAError>) -> Void)) {
        let params = ["username": username, "password": password]
        if let request = requestBuilder.buildRequest(endPoint: .login, params: params, requiresToken: false) {
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.authenticationFailed))
        }
    }
    
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, GAError>) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.errorFromServer(error: error)))
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            if !(200...299).contains(statusCode ?? -1) {
                completion(.failure(.errorFromApi(statusCode: statusCode ?? -1)))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noDataReceived))
                return
            }
            
            do {
                let apiInfo = try JSONDecoder().decode(T.self, from: data)
                completion(.success(apiInfo))
            } catch {
                completion(.failure(.errorParsingData))
            }
        }.resume()
    }
}
