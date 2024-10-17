//
//  GAObservable.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

// MARK: - GAObservable Class
/// Crea un tipo genérico para observar cambios en un valor.
class GAObservable<ObservedType> {
    
    private var _value: ObservedType // Valor almacenado
    
    // Closure para notificar a los observadores sobre el cambio de valor
    private var valueChanged: ((ObservedType) -> Void)?
    
    // MARK: - Public Property
    /// Propiedad para acceder y modificar el valor observado.
    var value: ObservedType {
        get {
            return _value
        }
        set {
            _value = newValue
            DispatchQueue.main.async {
                self.valueChanged?(self._value) // Notifica a los observadores en el hilo principal
            }
        }
    }
    
    // MARK: - Initializer
    /// Inicializa el valor almacenado.
    /// - Parameter value: Valor inicial.
    init(_ value: ObservedType) {
        self._value = value
    }
    
    // MARK: - Binding
    /// Asigna un closure que se ejecutará al cambiar el valor.
    /// - Parameter completion: Closure que recibe el nuevo valor.
    func bind(completion: ((ObservedType) -> Void)?) {
        valueChanged = completion
    }
}
