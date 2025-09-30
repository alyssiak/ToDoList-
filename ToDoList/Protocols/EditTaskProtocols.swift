import Foundation
import CoreData

enum EditMode {
    case create
    case edit(objectID: NSManagedObjectID)
}

// MARK: - View -> Presenter (события формы)
protocol EditTaskViewOutput: AnyObject {
    func viewDidLoad()
    func saveTapped(title: String, desc: String?)
    func cancelTapped()
}

// MARK: - Present -> View (что рисовать на форме)
protocol EditTaskViewInput: AnyObject {
    func fill(title: String, desc: String?)
    func showError(_ message: String)
    func close()
}

// MARK: - Presenter -> Interactor (работа с данными)
protocol EditTaskInteractorInput: AnyObject {
    func loadIfNeeded(mode: EditMode)
    func create(title: String, desc: String?)
    func update(objectID: NSManagedObjectID, title: String, desc: String?)
}

// MARK: - Interactor -> Presenter (результаты)
protocol EditTaskInteractorOutput: AnyObject {
    func didLoadForEdit(title: String, desc: String?)
    func didSave()
    func didFail(with error: Error)
}

//MARK: - Presenter -> Router (навигация)
protocol EditTaskRouterInput: AnyObject {
    func close()
}
