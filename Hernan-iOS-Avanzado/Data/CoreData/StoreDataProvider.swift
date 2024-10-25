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
            print("Error al limpiar la base de datos: \(error.localizedDescription)")
            throw GAError.coreDataError(error: error) // Lanzar el error para que lo maneje el caso de uso
        }
    }
}

// MARK: - Data Operations
extension StoreDataProvider {
    
    /// Inserta MOHero a partir de un array de ApiHero
    func add(heroes: [ApiHero]) {
        for hero in heroes {
            // Verificar que id y name no sean nil antes de agregar
            if let id = hero.id, let name = hero.name {
                let newHero = MOHero(context: context)
                newHero.id = id
                newHero.name = name
                newHero.info = hero.description
                newHero.favorite = hero.favorite ?? false
                newHero.photo = hero.photo
            } else {
                print("Error: Datos incompletos para el héroe \(hero)")
            }
        }
        // Guardar después de insertar todos los héroes
        save()
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
    func add(locations: [ApiLocation]) {
        for location in locations {
            // Verificar que id, latitude, y longitude no sean nil antes de agregar
            if let id = location.id, let latitude = location.latitude, let longitude = location.longitude {
                let newLocation = MOLocation(context: context)
                newLocation.id = id
                newLocation.latitude = latitude
                newLocation.longitude = longitude
                newLocation.date = location.date
                
                if let heroId = location.hero?.id {
                    let predicate = NSPredicate(format: "id == %@", heroId)
                    if let hero = fetchHeroes(filter: predicate).first {
                        newLocation.hero = hero
                        hero.addToLocations(newLocation)
                    }
                }
            } else {
                print("Error: Datos incompletos para la localización \(location)")
            }
        }
        save()  // Guardar después de insertar cada localización
    }
    
    /// Inserta MOTransformation a partir de un array de ApiTransformation
    func add(transformations: [ApiTransformation]) {
        for transformation in transformations {
            // Verificar que id y name no sean nil antes de agregar
            if let id = transformation.id, let name = transformation.name {
                let newTransformation = MOTransformation(context: context)
                newTransformation.id = id
                newTransformation.name = name
                newTransformation.info = transformation.description
                newTransformation.photo = transformation.photo
                
                if let heroId = transformation.hero?.id {
                    let predicate = NSPredicate(format: "id == %@", heroId)
                    if let hero = fetchHeroes(filter: predicate).first, hero.managedObjectContext != nil {
                        // El objeto aún es válido, puedes modificarlo
                        newTransformation.hero = hero
                        hero.addToTransformations(newTransformation)
                    } else {
                        print("El héroe ha sido eliminado del contexto o es nulo.")
                    }
                    
                }
            } else {
                print("Error: Datos incompletos para la transformación \(transformation)")
            }
        }
        save()  // Guardar después de insertar cada transformación
    }
}
