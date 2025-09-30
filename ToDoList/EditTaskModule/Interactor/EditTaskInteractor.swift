//
//  EditTaskInteractor.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import Foundation
import CoreData

final class EditTaskInteractor: EditTaskInteractorInput {
   
    weak var output: EditTaskInteractorOutput?
    private let backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext()
    
    func loadIfNeeded(mode: EditMode) {
        switch mode {
            case .create:
                break
            case .edit(let objectID):
                backgroundContext.perform {
                    let obj = try? self.backgroundContext.existingObject(with: objectID) as? TaskItem
                    let title = obj?.title ?? ""
                    let desc = obj?.desc
                    DispatchQueue.main.async {
                        self.output?.didLoadForEdit(title: title, desc: desc)
                    }
                }
        }
    }
    
    func create(title: String, desc: String?) {
        let ctx = CoreDataStack.shared.backgroundContext()
        ctx.perform {
            let task = TaskItem(context: ctx)
            task.id = UUID()
            task.title = title
            task.desc = desc
            task.createdAt = Date()
            task.isCompleted = false
            do {
                try ctx.save()
                DispatchQueue.main.async { self.output?.didSave() }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(with: error) }
            }
        }
    }
    
    func update(objectID: NSManagedObjectID, title: String, desc: String?) {
        let ctx = CoreDataStack.shared.backgroundContext()
        ctx.perform {
            guard let item = try? ctx.existingObject(with: objectID) as? TaskItem else { return }
            item.title = title
            item.desc = desc

            do {
              try ctx.save()
                DispatchQueue.main.async { self.output?.didSave() }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(with: error) }
            }
        }
    }
    
}
