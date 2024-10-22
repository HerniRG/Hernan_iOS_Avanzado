//
//  SecureDataStorageMock.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import Foundation
@testable import Hernan_iOS_Avanzado


///Mock para SecureDataStorage, implementa el protocol
/// Igual que SecureDataStorage pero en vez de usar KEyChain usamos Userdefaults
class SecureDataStorageMock: SecureDataStoreProtocol {
    
    private let kToken = "kToken"
    private var userDefaults = UserDefaults.standard
    
    func setToken(_ token: String) {
        userDefaults.set(token, forKey: kToken)
    }
    
    func getToken() -> String? {
        userDefaults.string(forKey: kToken)
    }
    
    func deleteToken() {
        userDefaults.removeObject(forKey: kToken)
    }
}
