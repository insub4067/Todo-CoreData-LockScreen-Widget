//
//  ContentViewModel.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import Foundation
import CoreData

final class ContenViewModel: ObservableObject {
    // MARK: - Variables
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

    // MARK: - View Interaction Functions
    func didSubmitTextField() {
        if !userInput.isEmpty {
            createTodo()
            getAllTodos()
        }
    }

    func didTapTodo(todo: TodoEntity) {
        editTodo(todo: todo)
        getAllTodos()
    }

    func didSwipeTodo(todo: TodoEntity) {
        deleteTodo(todo: todo)
        getAllTodos()
    }

    func didTapXbutton() {
        clearUserinput()
    }
}

// MARK: - DATA HANDLING FUNCTIONS
extension ContenViewModel {
    func clearUserinput() {
        userInput = ""
    }
}

// MARK: - CORE DATA FUNCTION CALLS
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
