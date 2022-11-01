//
//  Todo_Widget.swift
//  Todo-Widget
//
//  Created by Kim Insub on 2022/10/11.
//

import CoreData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let todos = CoreDataManager.shared.getAllTodos()
        let inProgressTodos = todos.filter { todo in
            todo.hasDone == false
        }
        let entry = SimpleEntry(date: Date(), todos: todos, inProgressTodos: inProgressTodos)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let todos = CoreDataManager.shared.getAllTodos()
        let inProgressTodos = todos.filter { todo in
            todo.hasDone == false
        }
        let entry = SimpleEntry(date: Date(), todos: todos, inProgressTodos: inProgressTodos)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate!))
        completion(timeline)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todos: [], inProgressTodos: [])
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todos: [TodoEntity]
    let inProgressTodos: [TodoEntity]
}

@main
struct Todo_Widget: Widget {
    let kind: String = "Todo_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Todo_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}
