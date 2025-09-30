//
//  ToDoListRouter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 27.09.2025.
//

import Foundation
import UIKit
import CoreData

class ToDoListRouter: ToDoListRouterInput {
    weak var ViewController: UIViewController?
    
    // Открыть экран создания новой задачи
    func showCreate(from view: UIViewController) {
        let vc = createEditTaskModule(mode: .create)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Открыть экран редактирования существующей задачи
    func showEdit(from view: UIViewController, objectID task: NSManagedObjectID) {
        let vc = createEditTaskModule(mode: .edit(objectID: task))
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Сборка модуля EditTask
    private func createEditTaskModule(mode: EditMode) -> UIViewController {
        let view = EditTaskViewController()
        let presenter = EditTaskPresenter(mode: mode)
        let interactor = EditTaskInteractor()
        let router = EditTaskRouter()
        
        view.output = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
