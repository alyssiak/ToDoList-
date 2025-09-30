import Foundation
import CoreData
import XCTest
@testable import ToDoList

final class TaskCoreDataTests: XCTestCase {
    var stack: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        stack = NSPersistentContainer(name: "ToDoList")
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        stack.persistentStoreDescriptions = [desc]
                stack.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
    }
    
    // Test #1: Cоздание и чтение задачи
    func testCreateAndFetchTask() throws {
        let ctx = stack.viewContext
        let item = TaskItem(context: ctx)
        item.id = UUID()
        item.title = "Test task"
        item.desc = "Some description"
        item.createdAt = Date()
        item.isCompleted = false
        try ctx.save()
        
        let req: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let results = try ctx.fetch(req)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test task")
        XCTAssertEqual(results.first?.isCompleted, false)
    }
    
    // Test #2: Переключение флага
    func testToggleCompleted() throws {
        let ctx = stack.viewContext
        let item = TaskItem(context: ctx)
        item.id = UUID()
        item.title = "Toogle me"
        item.createdAt = Date()
        item.isCompleted = false
        try ctx.save()
        
        let id = item.objectID
            if let same = try ctx.existingObject(with: id) as? TaskItem {
                same.isCompleted.toggle()
                try ctx.save()
            }
        let refreshed = try ctx.existingObject(with: id) as! TaskItem
        XCTAssertEqual(refreshed.isCompleted, true)
    }
    
    // Test #3: Удаление задачи
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
