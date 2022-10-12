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

    init() {
        getAllTodos()
    }

    let viewContext = CoreDataManager.shared.container.viewContext

    func didSubmitTextField() {
        createTodo()
        getAllTodos()
        userInput = ""
    }

    func didTapTodo(todo: TodoEntity) {
        editTodo(todo: todo)
        getAllTodos()
    }

    func didSwipeTodo(todo: TodoEntity) {
        deleteTodo(todo: todo)
        getAllTodos()
    }
}

extension ContenViewModel {
    func getAllTodos() {
        let response = CoreDataManager.shared.getAllTodos()
        todoList = response ?? [TodoEntity()]
    }

    func createTodo() {
        CoreDataManager.shared.createTodo(title: userInput)
    }

    func editTodo(todo: TodoEntity) {
        CoreDataManager.shared.editTodo(todo: todo)
    }

    func deleteTodo(todo: TodoEntity) {
        CoreDataManager.shared.deleteTodo(todo: todo)
    }
}
