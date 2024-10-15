//
//  HeroesViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

class HeroesViewModel {
    
    let useCase: HeroUseCase
    
    init(useCase: HeroUseCase) {
        self.useCase = useCase
    }
    
}

class HeroesViewController: UIViewController {
    
    private var viewModel: HeroesViewModel
    
    init(viewModel: HeroesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
