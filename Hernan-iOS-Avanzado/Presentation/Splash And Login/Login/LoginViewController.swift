//
//  LoginViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let token = "eyJraWQiOiJwcml2YXRlIiwiYWxnIjoiSFMyNTYiLCJ0eXAiOiJKV1QifQ.eyJpZGVudGlmeSI6IjdBQjhBQzRELUFEOEYtNEFDRS1BQTQ1LTIxRTg0QUU4QkJFNyIsImVtYWlsIjoiYmVqbEBrZWVwY29kaW5nLmVzIiwiZXhwaXJhdGlvbiI6NjQwOTIyMTEyMDB9.Dxxy91hTVz3RTF7w1YVTJ7O9g71odRcqgD00gspm30s"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func goToHeroesTapped(_ sender: Any) {
        SecureDataStore.shared.setToken(token)
        let heroesViewController = HeroesViewController()
        navigationController?.pushViewController(heroesViewController, animated: true)
    }
}
