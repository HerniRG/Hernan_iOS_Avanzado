//
//  SecureDataStore.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import KeychainSwift

protocol SecureDataStoreProtocol {
    func setToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

class SecureDataStore: SecureDataStoreProtocol {
    
    // MARK: - Properties
    private let kToken = "kToken"
    private let keychain = KeychainSwift()
    
    static let shared: SecureDataStore = .init()
    
    // MARK: - Token Management
    func setToken(_ token: String) {
        keychain.set(token, forKey: kToken)
    }
    
    func getToken() -> String? {
        return keychain.get(kToken)
    }
    
    func deleteToken() {
        keychain.delete(kToken)
    }
}
