//
//  CoreDataManager.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import Foundation
import CoreData

class CoreDataManager: ObservableObject {

    // MARK: - Properties
    static let shared = CoreDataManager()

    private let databaseName = "DataModel.sqlite"
    private let container = NSPersistentContainer(name: "DataModel")

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    private var oldStoreURL: URL {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "")
        }
        return directory.appendingPathComponent(databaseName)
    }

    private var sharedStoreURL: URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kim.TodoLockScreen") else {
            return URL(fileURLWithPath: "")
        }
        return container.appendingPathComponent(databaseName)
    }

    // MARK: - init
    private init() {
        loadStores()
        migrateStore()
        context.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Private Methods
private extension CoreDataManager {
    func loadStores() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func migrateStore() {
        let coordinator = container.persistentStoreCoordinator
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
        } catch {
            print(error.localizedDescription)
        }
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - CRUD Logic
extension CoreDataManager {
    func save() {
        do {
            try context.save()
        } catch {
            print("FAILED TO SAVE CONTEXT")
        }
    }

    func getAllTodos() -> [TodoEntity] {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        let result = try? context.fetch(fetchRequest)
        return result ?? []
    }

    func createTodo(title: String) {
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.title = title
        todo.createAt = Date()
        todo.hasDone = false
        save()
    }

    func editTodo(todo: TodoEntity) {
        todo.hasDone.toggle()
        save()
    }

    func deleteTodo(todo: TodoEntity) {
        context.delete(todo)
        save()
    }
}
