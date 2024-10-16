//
//  MOHero+CoreDataClass.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//
//

import Foundation
import CoreData

/// Clase generada por XCode de Core Data usando Editor-> Create NSMAnagedObject SubClasses
/// Necesario tener seleccionado el Modelo en el explorador.
@objc(MOHero)
public class MOHero: NSManagedObject {

}

extension MOHero {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOHero> {
        return NSFetchRequest<MOHero>(entityName: "CDHero")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var info: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var photo: String?
    @NSManaged public var locations: Set<MOLocation>?
    @NSManaged public var transformations: Set<MOTransformation>?

}

// MARK: Generated accessors for locations

// Modificado NSSet creado por XCODe por Set<MOClasss>
extension MOHero {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: MOLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: MOLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: Set<MOLocation>)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: Set<MOLocation>)

}

// MARK: Generated accessors for transformations
extension MOHero {

    @objc(addTransformationsObject:)
    @NSManaged public func addToTransformations(_ value: MOTransformation)

    @objc(removeTransformationsObject:)
    @NSManaged public func removeFromTransformations(_ value: MOTransformation)

    @objc(addTransformations:)
    @NSManaged public func addToTransformations(_ values: Set<MOTransformation>)

    @objc(removeTransformations:)
    @NSManaged public func removeFromTransformations(_ values: Set<MOTransformation>)

}

extension MOHero : Identifiable {

}
