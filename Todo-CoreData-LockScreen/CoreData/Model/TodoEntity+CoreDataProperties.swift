//
//  TodoEntity+CoreDataProperties.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/11/01.
//
//

import Foundation
import CoreData


extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var createAt: Date?
    @NSManaged public var hasDone: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?

}

extension TodoEntity : Identifiable {

}
