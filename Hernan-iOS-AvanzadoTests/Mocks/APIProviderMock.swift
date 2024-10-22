//
//  APIProviderMock.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

@testable import Hernan_iOS_Avanzado

class ApiProviderMock: ApiProviderProtocol {
    
    
    func login(username: String, password: String, completion: @escaping ((Result<String, Hernan_iOS_Avanzado.GAError>) -> Void)) {
        if username == "validUser" && password == "validPassword" {
            completion(.success("mockedToken123"))
        } else {
            completion(.failure(.authenticationFailed))
        }
    }
    
    
    func loadHeros(name: String, completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        do {
            let heroes = try MockData.mockHeroes()
            completion(.success(heroes))
        } catch {
            completion(.failure(GAError.noDataReceived))
        }
    }
    
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        let locations = [ApiLocation(id: "id", date: "date", latitude: "latitud", longitude: "0000", hero: nil)]
        completion(.success(locations))
    }
    
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        let trnasformations = [ApiTransformation(id: "id", name: "name", photo: "photo", description: "desc", hero: nil)]
        completion(.success(trnasformations))
    }
    
    
}

class ApiProviderErrorMock: ApiProviderProtocol {
    func login(username: String, password: String, completion: @escaping ((Result<String, Hernan_iOS_Avanzado.GAError>) -> Void)) {
        completion(.failure(.authenticationFailed))
    }
    
    func loadHeros(name: String, completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        completion(.failure(GAError.noDataReceived))
    }
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        completion(.failure(GAError.noDataReceived))
    }
    
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        completion(.failure(GAError.noDataReceived))
    }
}
