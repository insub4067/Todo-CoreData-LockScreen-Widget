//
//  CoreDataManager.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import Foundation
import CoreData

// com.kim.Todo-CoreData-LockScreen

class CoreDataManager: ObservableObject {
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

    private var isNeededToSaveNewURL: Bool {
        !FileManager.default.fileExists(atPath: oldStoreURL.path)
    }

    private init() {
        saveStoreURL(isNeededToSaveNewURL)
        loadStores()
        migrateStore()
        context.automaticallyMergesChangesFromParent = true
    }

    private func saveStoreURL(_ isNeededToSaveNewURL: Bool) {
        guard isNeededToSaveNewURL else { return }
        guard let description = container.persistentStoreDescriptions.first else { return }
        description.url = sharedStoreURL
    }

    private func loadStores() {
        container.loadPersistentStores { desc, error in
              if let error = error {
                  print(error.localizedDescription)
              }
        }
    }

    private func migrateStore() {
        let coordinator = container.persistentStoreCoordinator
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        // MARK: - Migrate Store
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
        } catch {
            print(error.localizedDescription)
        }
        // MARK: - Remove Old Store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension CoreDataManager {
    func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("FAILED TO SAVE CONTEXT")
        }
    }

    func getAllTodos() -> [TodoEntity] {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        let result = try? container.viewContext.fetch(fetchRequest)
        return result ?? []
    }

    func createTodo(title: String) {
        let todo = TodoEntity(context: container.viewContext)
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
        container.viewContext.delete(todo)
        save()
    }
}
