//
//  MOLocation+CoreDataClass.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//
//

import Foundation
import CoreData

/// Clase generada por XCode de Core Data usando Editor-> Create NSMAnagedObject SubClasses
/// Necesario tener seleccionado el Modelo en el explorador.
@objc(MOLocation)
public class MOLocation: NSManagedObject {

}

extension MOLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOLocation> {
        return NSFetchRequest<MOLocation>(entityName: "CDLocation")
    }

    @NSManaged public var id: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var date: String?
    @NSManaged public var hero: MOHero?

}

extension MOLocation : Identifiable {

}
