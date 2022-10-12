//
//  Todo_CoreData_LockScreenApp.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import SwiftUI

@main
struct Todo_CoreData_LockScreenApp: App {
    @StateObject private var coreDataManager = CoreDataManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}
