//
//  GAObservable.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

///Crea nuestro tipo genérico, dándole una propiedad para almacenar ese valor, y un inicializador para que podamos crearlo fácilmente. El valor almacenado es privado: no queremos que se modifique por accidente.

class GAObservable<ObservedType> {
    
    private var _value: ObservedType
    
    /// Enviará el valor actual a cualquiera que lo esté observando
    private var valueChanged: ((ObservedType) -> Void)?
    
    
    ///Creamos una propiedad de valor donde el valor almacenado puede ser manipulado de forma segura. Esto es diferente a la propiedad _value, que es privada - ésta está diseñada para ser modificada desde cualquier punto de la app, y ambas cambiarán, cambiará _value y enviará su nuevo valor al observador utilizando el closure valueChanged. Otra opción quizás más clara visualmente sería tener una función publica que actualice _value  y otra que lo devuelva. En lugar de usar  los observers set y get de una segunda variable.
    var value: ObservedType {
        get {
            return _value
        }
        set {
            _value = newValue
            DispatchQueue.main.async {
                self.valueChanged?(self._value)
            }
        }
    }
    
    /// Inicializa el valor almacenado
    init(_ value: ObservedType) {
        self._value = value
    }
    
    
    // Asigna el closure a Valuechanged"
    func bind(completion: ((ObservedType) -> Void)?) {
        valueChanged = completion
    }
}
