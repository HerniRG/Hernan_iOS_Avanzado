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
    
    static var managedModel: NSManagedObjectModel = {
        let bundle = Bundle(for: StoreDataProvider.self)
        guard let url = bundle.url(forResource: "Model", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Error loading model")
        }
        return model
    }()
    
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
        self.persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: Self.managedModel)
        if self.persistency == .inMemory {
            let persistentStore = persistentContainer.persistentStoreDescriptions.first
            persistentStore?.url = URL(filePath: "/dev/null")
        }
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Error loading BBDD \(error.localizedDescription)")
            }
        }
    }
    
    // Función para poder testar los casos de error de uan request.
    // Usa genérico para que valga para cualquier tipo de NSMAnagedObjet
    // Podríamos usar MOHero que  conforma NSFetchRequestResult pero nos limitaría para otras entidades
    func perform<T: NSFetchRequestResult>(request: NSFetchRequest<T>) throws -> [T] {
        return try context.fetch(request)
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
    
    /// Limpia la base de datos
    func clearBBDD() throws {
        let batchDeleteHeroes = NSBatchDeleteRequest(fetchRequest: MOHero.fetchRequest())
        let batchDeleteTransformations = NSBatchDeleteRequest(fetchRequest: MOTransformation.fetchRequest())
        let batchDeleteLocations = NSBatchDeleteRequest(fetchRequest: MOLocation.fetchRequest())
        
        do {
            try context.execute(batchDeleteHeroes)
            try context.execute(batchDeleteTransformations)
            try context.execute(batchDeleteLocations)
            context.reset()  // Limpiar el contexto después de cada batch delete
        } catch {
            debugPrint("Error al limpiar la base de datos: \(error.localizedDescription)")
            throw GAError.coreDataError(error: error) // Lanzar el error para que lo maneje el caso de uso
        }
    }
}

// MARK: - Data Operations
extension StoreDataProvider {
    
    /// Inserta MOHero a partir de un array de ApiHero
    func add(heroes: [ApiHero]) {
        for hero in heroes {
            guard let id = hero.id, let name = hero.name else {
                debugPrint("Error: Datos incompletos para el héroe \(hero)")
                continue  // Saltar al siguiente héroe si faltan datos
            }
            
            let newHero = MOHero(context: context)
            newHero.id = id
            newHero.name = name
            newHero.info = hero.description
            newHero.favorite = hero.favorite ?? false
            newHero.photo = hero.photo
        }
        save()  // Guardar después de insertar todos los héroes
    }
    
    /// Obtiene los héroes, filtrando según el NSPredicate
    func fetchHeroes(filter: NSPredicate?, sortAscending: Bool = true) -> [MOHero] {
        let request = MOHero.fetchRequest()
        
        if let filter = filter { request.predicate = filter }
        
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
    // MARK: - Evitar duplicación de Localizaciones con una búsqueda en Core Data
    func add(locations: [ApiLocation]) {
        for location in locations {
            guard let id = location.id, let latitude = location.latitude, let longitude = location.longitude else {
                debugPrint("Error: Datos incompletos para la localización \(location)")
                continue  // Saltar al siguiente si faltan datos
            }
            
            // Verificar si la localización ya existe en Core Data
            let fetchRequest: NSFetchRequest<MOLocation> = MOLocation.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let existingLocations = try context.fetch(fetchRequest)
                
                // Si ya existe, no la insertamos
                if !existingLocations.isEmpty {
                    debugPrint("Localización ya existente para el héroe")
                    continue
                }
                
            } catch {
                debugPrint("Error al verificar la existencia de la localización: \(error.localizedDescription)")
                continue
            }
            
            let newLocation = MOLocation(context: context)
            newLocation.id = id
            newLocation.latitude = latitude
            newLocation.longitude = longitude
            newLocation.date = location.date
            
            guard let heroId = location.hero?.id else { continue }
            
            let predicate = NSPredicate(format: "id == %@", heroId)
            guard let hero = fetchHeroes(filter: predicate).first else { continue }
            
            debugPrint("Contexto del héroe: \(String(describing: hero.managedObjectContext))")
            debugPrint("Contexto de la localización: \(String(describing: newLocation.managedObjectContext))")
            
            newLocation.hero = hero
            hero.addToLocations(newLocation)
        }
        save()  // Guardar después de insertar cada localización
    }
    
    /// Inserta MOTransformation a partir de un array de ApiTransformation
    // MARK: - Evitar duplicación de Transformaciones con una búsqueda en Core Data
    func add(transformations: [ApiTransformation]) {
        for transformation in transformations {
            guard let id = transformation.id, let name = transformation.name else {
                debugPrint("Error: Datos incompletos para la transformación \(transformation)")
                continue  // Saltar al siguiente si faltan datos
            }
            
            // Verificar si la transformación ya existe en Core Data
            let fetchRequest: NSFetchRequest<MOTransformation> = MOTransformation.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let existingTransformations = try context.fetch(fetchRequest)
                
                // Si ya existe, no la insertamos
                if !existingTransformations.isEmpty {
                    debugPrint("Transformación ya existente para el héroe \(String(describing: transformation.name))")
                    continue
                }
                
            } catch {
                debugPrint("Error al verificar la existencia de la transformación: \(error.localizedDescription)")
                continue
            }
            
            let newTransformation = MOTransformation(context: context)
            newTransformation.id = id
            newTransformation.name = name
            newTransformation.info = transformation.description
            newTransformation.photo = transformation.photo
            
            guard let heroId = transformation.hero?.id else { continue }
            
            let predicate = NSPredicate(format: "id == %@", heroId)
            guard let hero = fetchHeroes(filter: predicate).first, hero.managedObjectContext == context else {
                debugPrint("El héroe ha sido eliminado del contexto o es nulo.")
                continue
            }
            
            newTransformation.hero = hero
            hero.addToTransformations(newTransformation)
        }
        save()  // Guardar después de insertar cada transformación
    }
}
