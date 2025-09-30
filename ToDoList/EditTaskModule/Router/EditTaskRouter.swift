//
//  EditTaskRouter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import Foundation
import UIKit

class EditTaskRouter: EditTaskRouterInput {
    weak var viewController: UIViewController?
    
    // Закрыть экран редактирования (возврат назад)
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
