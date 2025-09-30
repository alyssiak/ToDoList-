//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 26.09.2025.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
            }
        
        // Главный контекст для UI
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    
    func backgroundContext() -> NSManagedObjectContext  {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
    
    func save(_ context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? viewContext
        var caughtError: Error?
        ctx.performAndWait {
            if ctx.hasChanges {
                do {
                    try ctx.save()
                }
                catch {
                    caughtError = error
                }
            }
        }
        if let e = caughtError { throw e }
    }
    
}
