//
//  HeroesViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

// MARK: - StatusHero Enum
enum StatusHero {
    case dataUpdated
    case error(msg: String)
    case none
    case clearDataSuccess
    case loading
}

// MARK: - HeroesViewModel Class
class HeroesViewModel {
    
    // MARK: - Properties
    let useCase: HeroUseCaseProtocol
    let clearDataUseCase: ClearDatabaseAndTokenUseCaseProtocol
    var statusHero: GAObservable<StatusHero> = GAObservable(StatusHero.none)
    var heroes: [Hero] = []
    
    // MARK: - Initializer
    init(useCase: HeroUseCaseProtocol = HeroUseCase(),
         clearDataUseCase: ClearDatabaseAndTokenUseCaseProtocol = ClearDatabaseAndTokenUseCase()) {
        self.useCase = useCase
        self.clearDataUseCase = clearDataUseCase
    }
    
    // MARK: - Load Data
    func loadData(filter: String?) {
        statusHero.value = .loading
        
        var predicate: NSPredicate?
        if let filter {
            predicate = NSPredicate(format: "name CONTAINS[cd] %@", filter)
        }
        
        // Carga de héroes
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
    
    // MARK: - Access Hero at Index
    func heroAt(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
    
    // MARK: - Clear Data
    func clearData() {
        clearDataUseCase.clearDatabaseAndToken { [weak self] result in
            switch result {
            case .success:
                self?.statusHero.value = .clearDataSuccess
            case .failure:
                self?.statusHero.value = .error(msg: "Error limpiando la base de datos")
            }
        }
    }
}
