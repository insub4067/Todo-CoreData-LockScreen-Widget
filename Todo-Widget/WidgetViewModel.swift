//
//  WidgetViewModel.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/12.
//

import Foundation
import CoreData

final class WidgetViewModel: ObservableObject {
    @Published var todoList: Array<TodoEntity> = [] {
        didSet {
            doneTodoList = todoList.filter({ todo in
                todo.hasDone == true
            })
            inProgressTodoList = todoList.filter({ todo in
                todo.hasDone == false
            })
        }
    }
    @Published var doneTodoList: Array<TodoEntity> = []
    @Published var inProgressTodoList: Array<TodoEntity> = []

    func getAllTodos(context: NSManagedObjectContext) {
        let response = CoreDataManager.shared.getAllTodos(context: context)
        todoList = response ?? [TodoEntity()]
    }
}
