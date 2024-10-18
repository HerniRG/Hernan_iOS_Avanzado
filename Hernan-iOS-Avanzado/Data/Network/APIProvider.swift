//
//  APIProvider.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import Foundation

// MARK: - ApiProviderProtocol
protocol ApiProviderProtocol {
    func loadHeros(name: String, completion: @escaping ((Result<[ApiHero], GAError>) -> Void))
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void))
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void))
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void))
}

// MARK: - APIProvider
class ApiProvider: ApiProviderProtocol {
    private let session: URLSession
    private let requestBuilder: GARequestBuilder
    
    // MARK: - Initializer
    init(session: URLSession = .shared, requestBuilder: GARequestBuilder = GARequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - Load Heroes
    func loadHeros(name: String = "", completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        do {
            let request = try requestBuilder.buildRequest(endPoint: .heroes, params: ["name": name])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Load Locations
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        do {
            let request = try requestBuilder.buildRequest(endPoint: .locations, params: ["id": id])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Load Transformations
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        do {
            let request = try requestBuilder.buildRequest(endPoint: .transformations, params: ["id": id])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Login
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void)) {
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(GAError.authenticationFailed))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        do {
            var request = try requestBuilder.buildRequest(endPoint: .login, params: [:], requiresToken: false)
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(GAError.errorFromApi(statusCode: 400))) // Error en la construcción de la petición
        }
    }
    
    // MARK: - Make Request
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, GAError>) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.errorFromServer(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noDataReceived)) // Si no se recibe una respuesta HTTP válida
                return
            }
            
            debugPrint("HTTP Status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                // Procesamos los datos
                guard let data = data, !data.isEmpty else {
                    completion(.failure(.noDataReceived))
                    return
                }
                
                if T.self == String.self {
                    if let token = String(data: data, encoding: .utf8) {
                        completion(.success(token as! T))
                    } else {
                        completion(.failure(.errorParsingData))
                    }
                    return
                }
                
                do {
                    let apiInfo = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(apiInfo))
                } catch {
                    completion(.failure(.errorParsingData))
                }
                
            case 401:
                // Manejo de fallo de autenticación
                completion(.failure(.authenticationFailed))
                
            default:
                completion(.failure(.errorFromApi(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
}
