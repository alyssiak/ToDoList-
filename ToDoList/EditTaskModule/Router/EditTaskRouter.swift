//
//  EditTaskRouter.swift
//  ToDoList
//
//  Created by Alice Kamyshenko on 28.09.2025.
//

import Foundation
import UIKit

final class EditTaskRouter: EditTaskRouterInput {
    weak var viewController: UIViewController?
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
