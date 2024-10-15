//
//  LoginViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    private var heroUseCase: HeroUseCase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicializamos el caso de uso antes de usarlo
        heroUseCase = HeroUseCase()
        
        // Cargamos los héroes y manejamos el resultado
        heroUseCase?.loadHeros(filter: nil, completion: { result in
            switch result {
            case .success(let heroes):
                // Imprimimos los héroes para verificar que llegan bien
                print("Héroes cargados con éxito:")
                heroes.forEach { hero in
                    print("Hero: \(hero.name), Favorito: \(hero.favorite)")
                }
                
            case .failure(let error):
                // Si hay un error, lo mostramos
                print("Error al cargar héroes: \(error)")
            }
        })
    }
}
