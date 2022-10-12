//
//  ContentViewModel.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import Foundation
import CoreData

final class ContenViewModel: ObservableObject {
    @Published var userInput = ""
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

    func didSubmitTextField(context: NSManagedObjectContext) {
        createTodo(context: context)
        getAllTodos(context: context)
    }

    func didTapTodo(todo: TodoEntity, context: NSManagedObjectContext) {
        editTodo(todo: todo, context: context)
        getAllTodos(context: context)
    }
}

extension ContenViewModel {
    func getAllTodos(context: NSManagedObjectContext) {
        let response = CoreDataManager.shared.getAllTodos(context: context)
        todoList = response ?? [TodoEntity()]
    }

    func createTodo(context: NSManagedObjectContext) {
        CoreDataManager.shared.createTodo(title: userInput, context: context)
        userInput = ""
    }

    func editTodo(todo: TodoEntity, context: NSManagedObjectContext) {
        CoreDataManager.shared.editTodo(todo: todo, context: context)
    }
}
