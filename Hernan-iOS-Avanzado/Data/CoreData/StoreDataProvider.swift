//
//  StoreDataProvider.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import CoreData

/// Stack de Core Data
class StoreDataProvider {
    
    static var shared: StoreDataProvider = .init()
    
    private let persistentContainer: NSPersistentContainer
    
    /// MAnagedObjectContex, indicamos el tipo de merge policy deseado
    /// para los objetos con la misma clave (Constraint añadidas en Model Editor
    private var context: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: "Model")
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Error loading BBDD \(error.localizedDescription)")
            }
        }
    }
    
    // Guarda el contexto si tiene camvbios pendientes
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


/// Extension para crear las funciones de insertar y recuperar datos de BBDD
extension StoreDataProvider {
    
    ///Inserta MOHero a partir de un array de ApiHero
    func add(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(context: context)
            newHero.id = hero.id
            newHero.name = hero.name
            newHero.favorite = hero.favorite ?? false
            newHero.photo = hero.photo
        }
        save()
    }
    
    ///Obtiene los heroes que podemos filtrar usando el filter
    func fetchHeroes(filter: NSPredicate?) -> [MOHero] {
        let request = MOHero.fetchRequest()
        request.predicate = filter
        
        do {
            return try context.fetch(request)
        } catch {
            debugPrint("Error loading heroes \(error.localizedDescription)")
            return []
        }
        // Si estuviéramos interesados solo en el número de registro
        // usar el método count de context es mucho más efectivo.
      //  try? context.count(for: request)
    }
    
    ///Inserta MOLocation a partir de un array de ApiLocation
    //////Importante asignar la relación con MOHero
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
    }
    
    ///Inserta MOTransformation a partir de un array de ApiHero
    ///Importante asignar la relación con MOHero
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
    }
}
