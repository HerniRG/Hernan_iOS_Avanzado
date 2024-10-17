//
//  StoreDataProvider.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import CoreData

// MARK: - Type of Persistency
enum TypePersistency {
    case disk
    case inMemory
}

// MARK: - Core Data Stack
class StoreDataProvider {
    
    static var shared: StoreDataProvider = .init()
    
    private let persistentContainer: NSPersistentContainer
    private let persistency: TypePersistency
    
    /// ManagedObjectContext, configurando la política de merge
    private var context: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }
    
    init(persistency: TypePersistency = .disk) {
        self.persistency = persistency
        self.persistentContainer = NSPersistentContainer(name: "Model")
        
        if self.persistency == .inMemory {
            let persintentStore = persistentContainer.persistentStoreDescriptions.first
            persintentStore?.url = URL(filePath: "/dev/null")
        }
        
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Error loading BBDD \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Save Context
    /// Guarda el contexto si hay cambios pendientes
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("Error saving context \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Data Operations
extension StoreDataProvider {
    
    /// Inserta MOHero a partir de un array de ApiHero
    func add(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(context: context)
            newHero.id = hero.id
            newHero.name = hero.name
            newHero.info = hero.description
            newHero.favorite = hero.favorite ?? false
            newHero.photo = hero.photo
        }
        save()
    }
    
    /// Obtiene los héroes, filtrando según el NSPredicate
    func fetchHeroes(filter: NSPredicate?, sortAscending: Bool = true) -> [MOHero] {
        let request = MOHero.fetchRequest()
        if let filter {
            request.predicate = filter
        }
        let sortDescriptor = NSSortDescriptor(keyPath: \MOHero.name, ascending: sortAscending)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let heroes = try context.fetch(request)
            return heroes
        } catch {
            debugPrint("Error loading heroes \(error.localizedDescription)")
            return []
        }
    }
    
    /// Inserta MOLocation a partir de un array de ApiLocation
    func add(locations: [ApiLocation]) {
        for location in locations {
            let newLocation = MOLocation(context: context)
            newLocation.id = location.id
            newLocation.latitude = location.latitude
            newLocation.longitude = location.longitude
            newLocation.date = location.date
            
            if let heroId = location.hero?.id {
                let predicate = NSPredicate(format: "id == %@", heroId)
                let hero = fetchHeroes(filter: predicate).first
                newLocation.hero = hero
            }
        }
        save()
    }
    
    /// Inserta MOTransformation a partir de un array de ApiTransformation
    func add(transformations: [ApiTransformation]) {
        for transformation in transformations {
            let newTransformation = MOTransformation(context: context)
            newTransformation.id = transformation.id
            newTransformation.name = transformation.name
            newTransformation.info = transformation.description
            newTransformation.photo = transformation.photo
            
            if let heroId = transformation.hero?.id {
                let predicate = NSPredicate(format: "id == %@", heroId)
                let hero = fetchHeroes(filter: predicate).first
                newTransformation.hero = hero
            }
        }
        save()
    }
    
    /// Limpia la base de datos
    func clearBBDD() throws {
        if context.hasChanges {
            try context.save()
        }
        
        let batchDeleteHeroes = NSBatchDeleteRequest(fetchRequest: MOHero.fetchRequest())
        let batchDeleteTransformations = NSBatchDeleteRequest(fetchRequest: MOTransformation.fetchRequest())
        let batchDeleteLocations = NSBatchDeleteRequest(fetchRequest: MOLocation.fetchRequest())
        
        let batchDeleteRequests: [NSBatchDeleteRequest] = [batchDeleteHeroes, batchDeleteTransformations, batchDeleteLocations]
        
        for request in batchDeleteRequests {
            do {
                try context.execute(request)
                context.reset()
            } catch {
                throw error 
            }
        }
    }
}
