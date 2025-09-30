//
//  EditTaskPresenter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import CoreData

final class EditTaskPresenter: EditTaskViewOutput, EditTaskInteractorOutput {
    weak var view: EditTaskViewInput?
    
    var interactor: EditTaskInteractorInput?
    var router: EditTaskRouterInput?
    private let mode: EditMode
    private var objectID: NSManagedObjectID?
    
    init(mode: EditMode) {
        self.mode = mode
        if case let .edit(objectID) = mode {
            self.objectID = objectID
        }
    }
    
    // MARK: - ViewOutput
    func viewDidLoad() {
        interactor?.loadIfNeeded(mode: mode)
    }
    
    func saveTapped(title: String, desc: String?) {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            view?.showError("Название задачи не может быть пустым")
            return
        }
        
        switch mode {
            case .create:
                interactor?.create(title: title, desc: desc)
            case .edit(let id):
                interactor?.update(objectID: id, title: title, desc: desc)
        }
    }
    func cancelTapped() {
        router?.close()
    }
    
    // MARK: - InteractorOutput
    func didLoadForEdit(title: String, desc: String?) {
        view?.fill(title: title, desc: desc)
    }
    
    func didSave() {
        view?.close()
    }
    
    func didFail(with error: any Error) {
        view?.showError(error.localizedDescription)
    }
}
