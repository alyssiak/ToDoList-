//
//  ToDoListInteractor.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 27.09.2025.
//

import Foundation
import CoreData

class ToDoListInteractor: ToDoListInteractorInput {
    weak var output: ToDoListInteractorOutput?
    
    // Берем контекст CoreData для фоновых операций
    private var currentQuery: String?
    private let userDefaults = UserDefaults.standard
    // MARK: Загружаем все задачи
    func fetchAll(matching query: String?) {
        self.currentQuery = query
        let bg = CoreDataStack.shared.backgroundContext()
        bg.perform {
            // 1) запрашиваем только objectID в фоне
            let req: NSFetchRequest<NSManagedObjectID> = TaskItem.fetchRequest() as! NSFetchRequest<NSManagedObjectID>
            req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            if let q = query, !q.isEmpty {
                req.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", q, q)
            }
            req.resultType = .managedObjectIDResultType
            
            let ids = (try? bg.fetch(req)) ?? []
            
            // 2) на главном контексте превращаем ID в объекты и отдаём во view
            DispatchQueue.main.async {
                let viewCtx = CoreDataStack.shared.viewContext
                viewCtx.perform {
                    var items: [TaskItem] = []
                    items.reserveCapacity(ids.count)
                    for id in ids {
                        if let obj = try? viewCtx.existingObject(with: id) as? TaskItem {
                            items.append(obj)
                        }
                    }
                    self.output?.didLoad(tasks: items)
                }
            }
        }
    }
            
    
    //MARK: Переключение статуса задачи
    func toggle(objectID: NSManagedObjectID) {
        let ctx = CoreDataStack.shared.backgroundContext()
        ctx.perform {
            // Пробуем достать объект по ID
            if let item = try? ctx.existingObject(with: objectID) as? TaskItem {
            item.isCompleted.toggle()
            do {
                try ctx.save()
                DispatchQueue.main.async { self.output?.didSave() }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(error) }
                }
            }
        }
    }
    
    func delete(objectID: NSManagedObjectID) {
        let ctx = CoreDataStack.shared.backgroundContext()
        ctx.perform {
            // Пробуем достать объект
            if let obj = try? ctx.existingObject(with: objectID) as? TaskItem {
                ctx.delete(obj)
                do {
                    try ctx.save()
                    DispatchQueue.main.async { self.output?.didSave() }
                } catch {
                    DispatchQueue.main.async { self.output?.didFail(error) }
                    }
                }
            }
    }
    
    // MARK: - Импорт задач из API ( 1 раз)
    func importIfNeeded() {
        // Проверяем импортировали ли
        if userDefaults.bool(forKey: "isImported") { return }
        let bg = CoreDataStack.shared.backgroundContext()
        bg.perform {
            let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
            request.fetchLimit = 1
            
            let count = (try? bg.count(for: request)) ?? 0
            if count > 0 {
            
                self.userDefaults.set(true, forKey: "isImported")
                return
            }
            // если пусто — грузим из API; loadFromAPI сама создаст контекст и сохранит
            self.loadFromAPI()
        }
    }
    
    // MARK: Загрузка API
    private func loadFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async { self.output?.didFail(error) }
                return
            }
            guard let data = data else { return }

            struct Response: Decodable {
                struct Todo: Decodable { let todo: String; let completed: Bool }
                let todos: [Todo]
            }

            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                let todos = response.todos

                let ctx = CoreDataStack.shared.backgroundContext() // ← свежий фон. контекст
                ctx.perform {
                    for t in todos {
                        let item = TaskItem(context: ctx)
                        item.id = UUID()
                        item.title = t.todo
                        item.desc = nil
                        item.createdAt = Date()
                        item.isCompleted = t.completed
                    }

                    do {
                        try ctx.save()
                        UserDefaults.standard.set(true, forKey: "isImported")
                        DispatchQueue.main.async { self.output?.didSave() }
                    } catch {
                        DispatchQueue.main.async { self.output?.didFail(error) }
                    }
                }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(error) }
            }
        }.resume()
    }
}
