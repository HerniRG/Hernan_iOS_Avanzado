//
//  LoginViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 17/10/24.
//

import Foundation

// MARK: - StatusLogin
// Definimos los posibles estados del Login
enum StatusLogin {
    case success
    case error(msg: String)
    case none
    case loading
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
            statusLogin.value = .error(msg: "El email está vacío.")
            return
        }
        
        guard !password.isEmpty else {
            statusLogin.value = .error(msg: "La contraseña está vacía.")
            return
        }
        
        // Si las credenciales no están vacías, iniciamos el proceso de login
        statusLogin.value = .loading
        
        loginUseCase.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.statusLogin.value = .success
            case .failure:
                // Si hay un error en el login, mostramos un mensaje de error
                self?.statusLogin.value = .error(msg: "Fallo al iniciar sesión")
            }
        }
    }
}
