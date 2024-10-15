//
//  MOTransformation+CoreDataClass.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//
//

import Foundation
import CoreData

/// Clase generada por XCode de Core Data usando Editor-> Create NSMAnagedObject SubClasses
/// Necesario tener seleccionado el Modelo en el explorador.
@objc(MOTransformation)
public class MOTransformation: NSManagedObject {

}

extension MOTransformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOTransformation> {
        return NSFetchRequest<MOTransformation>(entityName: "CDTransformation")
    }

    @NSManaged public var id: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var photo: String?
    @NSManaged public var hero: MOHero?

}

extension MOTransformation : Identifiable {

}
