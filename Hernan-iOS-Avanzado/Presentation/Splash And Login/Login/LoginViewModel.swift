//
//  LoginViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 17/10/24.
//

import Foundation

// MARK: - StatusLogin
enum StatusLogin: Equatable {
    case success
    case error(msg: String)
    case none
    case loading
}

// MARK: - LoginError
enum LoginError: String {
    case emptyUsername = "El email está vacío."
    case emptyPassword = "La contraseña está vacía."
    case genericError = "Fallo al iniciar sesión"
}

// MARK: - LoginViewModel
class LoginViewModel {
    
    let loginUseCase: LoginUseCaseProtocol
    var statusLogin: GAObservable<StatusLogin> = GAObservable(.none)
    
    // MARK: - Initializer
    init(loginUseCase: LoginUseCaseProtocol = LoginUseCase()) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Login Function
    func login(username: String, password: String) {
        // Validamos si el usuario o la contraseña están vacíos
        guard !username.isEmpty else {
            statusLogin.value = .error(msg: LoginError.emptyUsername.rawValue)
            return
        }
        
        guard !password.isEmpty else {
            statusLogin.value = .error(msg: LoginError.emptyPassword.rawValue)
            return
        }
        
        statusLogin.value = .loading
        
        loginUseCase.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.statusLogin.value = .success
            case .failure:
                self?.statusLogin.value = .error(msg: LoginError.genericError.rawValue)
            }
        }
    }
}
