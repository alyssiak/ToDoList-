//
//  ToDoListPresenter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 27.09.2025.
//

import Foundation
import UIKit
import CoreData

final class ToDoListPresenter: ToDoListViewOutput, ToDoListInteractorOutput {
    
    weak var view: ToDoListViewInput?
    weak var fromVC: UIViewController?
    
    var interactor: ToDoListInteractorInput?
    var router: ToDoListRouterInput?
    
    private var items: [ToDoItemViewModel] = []
    
    // MARK: - View -> Presenter
    func viewDidLoad() {
        interactor?.importIfNeeded()
        interactor?.fetchAll(matching: nil)
    }
    
    func addTapped() {
        if let vc = fromVC {
            router?.showCreate(from: vc)
        }
    }
    
    func searchChanged(_ searchText: String) {
        let q = searchText.isEmpty ? nil : searchText
        interactor?.fetchAll(matching: q)
    }
    
    func toggleCompleted(at index: Int) {
        if index >= 0 && index < items.count {
            interactor?.toggle(objectID: items[index].objectID)
        }
    }
    
    func delete(at index: Int) {
        if index >= 0 && index < items.count {
            interactor?.delete(objectID: items[index].objectID)
        }
    }
    
    func edit(at index: Int) {
        if index >= 0 && index < items.count {
            if let vc = fromVC {
                router?.showEdit(from: vc, objectID: items[index].objectID)
            }
        }
    }
    
    // MARK: - Interactor -> Presenter
    func didLoad(tasks: [TaskItem]) {
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
        interactor?.fetchAll(matching: nil)
    }
}
