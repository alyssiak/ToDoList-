//
//  EditTaskInteractor.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import Foundation
import CoreData


class EditTaskInteractor: EditTaskInteractorInput {
   
    
    weak var output: EditTaskInteractorOutput? // чтобы отправлять результат презентеру
    private let backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext()
    
    // Загружаем данные, если редактируем существующую задачу
    func loadIfNeeded(mode: EditMode) {
        switch mode {
            case .create:
                // если создаём — ничего не загружаем
                break
            case .edit(let objectID):
                // если редактируем — достаём объект из Core Data
                backgroundContext.perform {
                    let obj = try? self.backgroundContext.existingObject(with: objectID) as? TaskItem
                    let title = obj?.title ?? ""
                    let desc = obj?.desc
                    
                    // результат отдаём презентеру на главном потоке
                    DispatchQueue.main.async {
                        self.output?.didLoadForEdit(title: title, desc: desc)
                    }
                }
        }
    }
    
    // Создание новой задачи
    func create(title: String, desc: String?) {
        let ctx = CoreDataStack.shared.backgroundContext()
        ctx.perform {
            let task = TaskItem(context: ctx)
            task.id = UUID()
            task.title = title
            task.desc = desc
            task.createdAt = Date()
            task.isCompleted = false
            
            // сохраняем
            
            // Всё, что может «бросить» ошибку, оборачиваем в do { }
            do {
                try ctx.save()
                DispatchQueue.main.async { self.output?.didSave() }
                
            // Если ошибка случается → Swift перескакивает в catch { }.
            } catch {
                DispatchQueue.main.async { self.output?.didFail(with: error) }
            }
        }
    }
    
    // Обновление существующей задачи
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
