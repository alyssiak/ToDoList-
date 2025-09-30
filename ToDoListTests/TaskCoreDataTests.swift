import Foundation
import CoreData
import XCTest
@testable import ToDoList

// создаем коробку для всех тестов
final class TaskCoreDataTests: XCTestCase {
    // здесь мы будем держать CoreData в памяти (тестовый контейнер)
    var stack: NSPersistentContainer!
    
    // setUp() запускается перед каждым тестом.
    override func setUp() {
        super.setUp()
        // Мы создаём контейнер Core Data, но не с SQLite-файлом, а с NSInMemoryStoreType (только в памяти).
        stack = NSPersistentContainer(name: "ToDoList")
        
        // Создаём описание хранилища (NSPersistentStoreDescription).
        let desc = NSPersistentStoreDescription()

        //Указываем .type = NSInMemoryStoreType → это значит: храним всё в оперативке, ничего на диск не пишем. Удобно для тестов.
        desc.type = NSInMemoryStoreType
        
        // Загружаем хранилище через loadPersistentStores.
        stack.persistentStoreDescriptions = [desc]
        
        // XCTAssertNil(error) — убеждаемся, что не было ошибок. Если будут — тест сразу упадёт
        stack.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
    }
    
    // Первый тест — создание и чтение задачи
    func testCreateAndFetchTask() throws {
        // берем контекст
        let ctx = stack.viewContext
        // Создаём новую задачу (TaskItem).
        let item = TaskItem(context: ctx)
        //Заполняем поля (UUID, title, description, дата, статус).
        item.id = UUID()
        item.title = "Test task"
        item.desc = "Some description"
        item.createdAt = Date()
        item.isCompleted = false
        // Сохраняем изменения в контексте.
        try ctx.save()
        
        // Создаём запрос (fetch request) на все объекты типа TaskItem.
        let req: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        
        // Выполняем запрос → получаем массив results.
        let results = try ctx.fetch(req)
        
        // XCTAssertEqual — проверки (assertы).
        // Убеждаемся, что нашли ровно одну задачу
        XCTAssertEqual(results.count, 1)
        
        // что у неё правильный заголовок
        XCTAssertEqual(results.first?.title, "Test task")
        
        // и что она невыполненная.
        XCTAssertEqual(results.first?.isCompleted, false)
    }
    
    // Тест на переключение флага
    func testToggleCompleted() throws {
        let ctx = stack.viewContext
        
        let item = TaskItem(context: ctx)
        item.id = UUID()
        item.title = "Toogle me"
        item.createdAt = Date()
        item.isCompleted = false
        
        try ctx.save()
        
        let id = item.objectID

            // 2) Act: переключаем флаг у ТОГО ЖЕ объекта и сохраняем
            if let same = try ctx.existingObject(with: id) as? TaskItem {
                same.isCompleted.toggle()   // false -> true
                try ctx.save()
            }

            // 3) Assert: читаем тот же объект и проверяем значение
            let refreshed = try ctx.existingObject(with: id) as! TaskItem
        // Проверяем, что теперь isCompleted == true.
        XCTAssertEqual(refreshed.isCompleted, true)
    }
    
    func testDeleteTask() throws {
        let ctx = stack.viewContext
        
        let item = TaskItem(context: ctx)
        item.id = UUID()
        item.title = "Delete task"
        item.desc = "Temporary description"
        item.createdAt = Date()
        item.isCompleted = false
        try ctx.save()
        
        let req: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        var results = try ctx.fetch(req)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Delete task")
        XCTAssertEqual(results.first?.desc, "Temporary description")
        
        ctx.delete(item)
        try ctx.save()
        
        results = try ctx.fetch(req)
        XCTAssertTrue(results.isEmpty)
    }
}
