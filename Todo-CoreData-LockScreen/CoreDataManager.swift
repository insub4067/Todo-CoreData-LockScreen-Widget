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
    let container = NSPersistentContainer(name: "DataModel")
    let databaseName = "DataModel.sqlite"

    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName)
    }

    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kim.TodoLockScreen")!
        return container.appendingPathComponent(databaseName)
    }

    init() {
        print("core data init")

        if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            print("old store doesn't exist. Using new shared URL")
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }

        print("Container URL = \(container.persistentStoreDescriptions.first!.url!)")

        container.loadPersistentStores { desc, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }

        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func migrateStore(for container: NSPersistentContainer) {
        print("Went into MigrateStore")
        let coordinator = container.persistentStoreCoordinator

        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        print("old store no longer exists")

        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("Migration Succeed")
        } catch {
            fatalError("Unable to migrate to shared store")
        }

        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("Old Store Deleted")
        } catch {
            print("Unable to delete oldStore")
        }
    }
}

extension CoreDataManager {
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("FAILED TO SAVE CONTEXT")
        }
    }

    func getAllTodos(context: NSManagedObjectContext) -> Array<TodoEntity>? {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        let result = try? context.fetch(fetchRequest)
        return result
    }

    func createTodo(title: String, context: NSManagedObjectContext) {
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.title = title
        todo.createAt = Date()
        todo.hasDone = false
        save(context: context)
    }

    func editTodo(todo: TodoEntity, context: NSManagedObjectContext) {
        todo.hasDone.toggle()
        save(context: context)
    }
}
