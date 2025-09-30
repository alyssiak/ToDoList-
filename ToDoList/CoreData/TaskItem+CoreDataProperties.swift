//
//  TaskItem+CoreDataProperties.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 26.09.2025.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var id: UUID?

}

extension TaskItem : Identifiable {

}
