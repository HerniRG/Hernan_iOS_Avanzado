//
//  HeroesViewModel.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import Foundation

// MARK: - StatusHero Enum
enum StatusHero: Equatable {
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
    var isAscendingOrder: Bool = true // Propiedad para almacenar el estado del orden
    
    // MARK: - Initializer
    init(useCase: HeroUseCaseProtocol = HeroUseCase(),
         clearDataUseCase: ClearDatabaseAndTokenUseCaseProtocol = ClearDatabaseAndTokenUseCase()) {
        self.useCase = useCase
        self.clearDataUseCase = clearDataUseCase
    }
    
    // MARK: - Load Data
    func loadData(filter: String?) {
        statusHero.value = .loading
        let predicate = createPredicate(filter: filter)
        
        useCase.loadHeros(filter: predicate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let heroes):
                    self?.heroes = heroes
                    self?.sortHeroes()
                    self?.statusHero.value = .dataUpdated
                case .failure(let error):
                    self?.statusHero.value = .error(msg: error.description)
                }
            }
        }
    }
    
    private func createPredicate(filter: String?) -> NSPredicate? {
        guard let filter = filter else { return nil }
        return NSPredicate(format: "name CONTAINS[cd] %@", filter)
    }
    
    // MARK: - Access Hero at Index
    func heroAt(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
    
    // MARK: - Ordenar héroes
    func sortHeroes() {
        if isAscendingOrder {
            self.heroes.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        } else {
            self.heroes.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        }
        self.statusHero.value = .dataUpdated
    }
    
    // MARK: - Clear Data
    func clearData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.clearDataUseCase.clearDatabaseAndToken { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.statusHero.value = .clearDataSuccess
                    case .failure:
                        self?.statusHero.value = .error(msg: "Error limpiando la base de datos, pero continuando con el logout.")
                        self?.statusHero.value = .clearDataSuccess
                    }
                }
            }
        }
    }
}
