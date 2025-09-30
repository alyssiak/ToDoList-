//
//  EditTaskPresenter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import CoreData

// Presenter связывает View ↔ Interactor ↔ Router
class EditTaskPresenter: EditTaskViewOutput, EditTaskInteractorOutput {
    // берем экран (форму)
    weak var view: EditTaskViewInput?
    
    // работа с данными (CoreData)
    var interactor: EditTaskInteractorInput?
    
    // навигация (закрыть экран)
    var router: EditTaskRouterInput?
    
    // Текущий режим: create или edit
    private let mode: EditMode
    private var objectID: NSManagedObjectID?

    
    init(mode: EditMode) {
        self.mode = mode
        if case let .edit(objectID) = mode {
            self.objectID = objectID
        }
    }
    
    // MARK: - ViewOutput
    // (то, что приходит от экрана)

    // Экран загрузился → нужно подготовить данные
    func viewDidLoad() {
        // если редактируем задачу, интерактор сам подгрузит её
        interactor?.loadIfNeeded(mode: mode)
    }
    
    // Пользователь нажал "Сохранить"
    func saveTapped(title: String, desc: String?) {
        // 1. Проверяем, что название не пустое
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            view?.showError("Название задачи не может быть пустым")
            return
        }
        
        // 2. В зависимости от режима: создаем или обновляем
        switch mode {
                case .create:
                interactor?.create(title: title, desc: desc)
            case .edit(let id):
                interactor?.update(objectID: id, title: title, desc: desc)
        }
    }
    
    // Пользователь нажал "Отмена"
    func cancelTapped() {
        router?.close()
    }
    
    // MARK: - InteractorOutput
    // (то, что интерактор возвращает нам)
    

    // Данные для формы редактирования подгружены
    func didLoadForEdit(title: String, desc: String?) {
        // Заполняем поля в экране
        view?.fill(title: title, desc: desc)
    }
    
    // Задача успешно сохранена (новая или обновленная)
    func didSave() {
        view?.close()
    }
    
    // Что-то пошло не так при работе с Core Data
    func didFail(with error: any Error) {
        view?.showError(error.localizedDescription)
    }
    
    
}
