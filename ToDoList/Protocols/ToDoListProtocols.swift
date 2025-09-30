//
//  ToDoListProtocols.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 26.09.2025.
//

import Foundation
import CoreData
import UIKit

// MARK: View -> Presenter (события от экрана спискка)
protocol ToDoListViewOutput: AnyObject {
    func viewDidLoad()
    func addTapped()
    func viewWillAppear()
    func searchChanged(_ searchText: String)
    func toggleCompleted(at index: Int)
    func delete(at index: Int)
    func edit(at index: Int)
}

// MARK: Presenter -> View (что показывать на экране списка)
protocol ToDoListViewInput: AnyObject {
    func show(items: [ToDoItemViewModel])
    func showEmpty()
    func showError(_ message: String)
}

// MARK: Presenter -> Interactor (операции с данными для списка)
protocol ToDoListInteractorInput: AnyObject {
    func fetchAll(matching query: String?)
    func toggle(objectID: NSManagedObjectID)
    func delete(objectID: NSManagedObjectID)
    
    // Импорт с API по ТЗ — один раз
    func importIfNeeded()
    }

// MARK: Interactor -> Presenter (результаты операций)
    protocol ToDoListInteractorOutput: AnyObject {
        func didLoad(tasks: [TaskItem])
        func didFail(_ error: Error)
        func didSave()
    }
    
// MARK: Presenter -> Router (навигация)
    protocol ToDoListRouterInput: AnyObject {
        func showCreate(from view: UIViewController)
        func showEdit(from view: UIViewController, objectID task: NSManagedObjectID)
    }
    
// MARK: ViewModel для таблицы
    struct ToDoItemViewModel {
        let title: String
        let desc: String?
        let isCompleted: Bool
        let createdAt: Date
        let objectID: NSManagedObjectID

    }

