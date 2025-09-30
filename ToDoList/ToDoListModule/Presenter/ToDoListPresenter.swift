//
//  ToDoListPresenter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 27.09.2025.
//

import Foundation
import UIKit
import CoreData

class ToDoListPresenter: ToDoListViewOutput, ToDoListInteractorOutput {
    
    // View, куда даем результат
    weak var view: ToDoListViewInput?
    
    // Интерактор, который работает с данными
    var interactor: ToDoListInteractorInput?
    
    // Роутер для навигации
    var router: ToDoListRouterInput?
    
    // Контроллер, из которого открываем экраны
    weak var fromVC: UIViewController?
    
    // Текущие элементы таблицы
    private var items: [ToDoItemViewModel] = []
        
    // MARK: - View -> Presenter
    func viewDidLoad() {
        // При первом запуске пробуем импорт и грузим список
        interactor?.importIfNeeded()
        interactor?.fetchAll(matching: nil)
    }
    
    func addTapped() {
        // Открываем экран создания задачи
        if let vc = fromVC {
            router?.showCreate(from: vc)
        }
    }
    
    func searchChanged(_ searchText: String) {
        // Передаем поисковую строку интерактору (пустая строка = nil)
        let q = searchText.isEmpty ? nil : searchText
        interactor?.fetchAll(matching: q)
    }
    
    func toggleCompleted(at index: Int) {
        // Проверяем индекс и просим интерактор переключить статус
        if index >= 0 && index < items.count {
            interactor?.toggle(objectID: items[index].objectID)
        }
    }
    
    func delete(at index: Int) {
        // Проверяем индекс и просить интерактор удалить
        if index >= 0 && index < items.count {
            interactor?.delete(objectID: items[index].objectID)
        }
    }
    
    func edit(at index: Int) {
        // Проверяем индекс и открываем экран редактирования
        if index >= 0 && index < items.count {
            if let vc = fromVC {
                router?.showEdit(from: vc, objectID: items[index].objectID)
            }
        }
    }
    
    // MARK: - Interactor -> Presenter
    func didLoad(tasks: [TaskItem]) {
        // преобразуем объекты CoreData (TaskItem) в модели для таблицы (ToDoItemViewModel)
        var result: [ToDoItemViewModel] = []
        for task in tasks {
            if let title = task.title, let createdAt = task.createdAt {
                let vm = ToDoItemViewModel(
                    title: title,
                    desc: task.desc,
                    isCompleted: task.isCompleted,
                    createdAt: createdAt,
                    objectID: task.objectID
                )
                result.append(vm)
            }
        }
        items = result
        
        // Показываем список или пустой экран
        if result.isEmpty {
            view?.showEmpty()
        } else {
            view?.show(items: result)
        }
    }
    
    func didFail(_ error: any Error) {
        view?.showError(error.localizedDescription)
    }
    
    func didSave() {
        interactor?.fetchAll(matching: nil)
    }
    
    func viewWillAppear() {
        interactor?.fetchAll(matching: nil) // рефетч перед показом
    }
}
