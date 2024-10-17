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
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void))
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
    
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void)) {
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(.authenticationFailed))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        if var request = requestBuilder.buildRequest(endPoint: .login, params: [:], requiresToken: false) {
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            print("Login request: \(request)")
            
            makeRequest(request: request, completion: completion)
        } else {
            completion(.failure(.authenticationFailed))
        }
    }
    
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, GAError>) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(.errorFromServer(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noDataReceived)) // Si no se recibe una respuesta HTTP válida
                return
            }
            
            print("HTTP Status: \(httpResponse.statusCode)")
            
            // Manejo del código de estado
            switch httpResponse.statusCode {
            case 200:
                // Si el estado es 200, procesamos los datos
                guard let data = data, !data.isEmpty else {
                    completion(.failure(.noDataReceived))
                    return
                }
                
                // Verifica si el tipo esperado es un `String`
                if T.self == String.self {
                    if let token = String(data: data, encoding: .utf8) {
                        print("Received token: \(token)")
                        completion(.success(token as! T))
                    } else {
                        completion(.failure(.errorParsingData)) // Error al parsear el token como String
                    }
                    return
                }
                
                do {
                    let apiInfo = try JSONDecoder().decode(T.self, from: data)
                    print("Received data: \(apiInfo)")
                    completion(.success(apiInfo))
                } catch {
                    print("Error parsing data: \(error.localizedDescription)")
                    completion(.failure(.errorParsingData))
                }
                
            case 401:
                // Manejo del fallo de autenticación
                print("Authentication failed: 401 Unauthorized")
                completion(.failure(.authenticationFailed))
                
            default:
                // Manejo de otros códigos de estado
                print("Received HTTP error: \(httpResponse.statusCode)")
                completion(.failure(.errorFromApi(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    
    
    
}
