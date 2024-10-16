//
//  HeroesViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

enum StatusHero {
    case dataUpdated
    case error(msg: String)
    case none
}

class HeroesViewModel {
    
    let useCase: HeroUseCaseProtocol
    var statusHero: GAObservable<StatusHero> = GAObservable(StatusHero.none)
    var heroes: [Hero] = []
    
    init(useCase: HeroUseCaseProtocol = HeroUseCase()) {
        self.useCase = useCase
    }
    
    func loadData(filter: String?) {
        var predicate: NSPredicate?
        if let filter {
            predicate = NSPredicate(format: "name CONTAINS[cd] %@", filter)
        }
        useCase.loadHeros(filter: predicate) { [weak self] result in
            switch result {
            case .success(let heroes):
                self?.heroes = heroes
                self?.statusHero.value = .dataUpdated
            case .failure(let error):
                self?.statusHero.value = .error(msg: error.description)
            }
        }
    }
    
    func heroAt(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
}
