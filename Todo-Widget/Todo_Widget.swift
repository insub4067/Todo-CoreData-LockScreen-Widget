//
//  Todo_Widget.swift
//  Todo-Widget
//
//  Created by Kim Insub on 2022/10/11.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: TimelineProvider {

    let viewContext = CoreDataManager.shared.container.viewContext

    var todoFetchRequest: NSFetchRequest<TodoEntity> {
        let request = TodoEntity.fetchRequest()
        return request
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {

        do {
            let allTodos = try viewContext.fetch(todoFetchRequest)
            let inProgressTodos = allTodos.filter { todo in
                todo.hasDone == false
            }
            let entry = SimpleEntry(date: Date(), allTodos: allTodos, inProgressTodos: inProgressTodos)
            completion(entry)
        } catch {
            print("❌ Widget Failed to fetch todos in snapshot")
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {

        do {
            let allTodos = try viewContext.fetch(todoFetchRequest)
            let inProgressTodos = allTodos.filter { todo in
                todo.hasDone == false
            }

            let entry = SimpleEntry(date: Date(), allTodos: allTodos, inProgressTodos: inProgressTodos)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate!))
            completion(timeline)
        } catch {
            print("❌ Widget Failed to fetch todos in snapshot")
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), allTodos: [], inProgressTodos: [])
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let allTodos: [TodoEntity]
    let inProgressTodos: [TodoEntity]
}

struct Todo_WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    static let url = URL(string: "widget-deepLink://")!

    var body: some View {
        switch widgetFamily {
        // MARK: - LockScreenRectangle
        case .accessoryCircular:
            Gauge(value: calculateGaugeValue()) {
                Text("TODO")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        // MARK: - LockScreenRectangle
        case .accessoryRectangular:
            Group {
                if entry.inProgressTodos.isEmpty {
                    Text("⚠️투두가 비었습니다")
                        .fontWeight(.bold)
                } else {
                    VStack {
                        ForEach(validateLenghtForLockscreen(), id: \.self) { todo in
                            HStack {
                                Image(systemName: "square")
                                Text(todo.title ?? "")
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(.black)
            .cornerRadius(10)
        // MARK: - WidgetSmall
        default:
            if entry.inProgressTodos.isEmpty {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text("투두")
                                .font(.caption)
                                .opacity(0.3)
                        }
                        Spacer()
                    }
                    Text("⚠️투두가 비었습니다")
                        .fontWeight(.bold)
                        .font(.title)
                        .opacity(0.6)
                }
                .padding()
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Text("투두")
                            .font(.caption)
                            .opacity(0.3)
                    }
                    ForEach(validateLenghtForWidget(), id: \.self) { todo in
                        HStack {
                            Image(systemName: "square")
                            Text(todo.title ?? "")
                                .lineLimit(1)
                            Spacer()
                        }
                        .foregroundColor(.black)
                        .opacity(0.8)
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }

    func calculateGaugeValue() -> Float {
        let total = entry.allTodos.count
        let hasDone = total-entry.inProgressTodos.count
        return Float(hasDone)/Float(total)
    }

    func validateLenghtForLockscreen() -> Array<TodoEntity> {
        if entry.inProgressTodos.count > 3 {
            return Array(entry.inProgressTodos[0...2])
        } else {
            return entry.inProgressTodos
        }
    }

    func validateLenghtForWidget() -> Array<TodoEntity> {
        if entry.inProgressTodos.count > 5 {
            return Array(entry.inProgressTodos[0...5])
        } else {
            return entry.inProgressTodos
        }
    }
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

//struct Todo_Widget_Previews: PreviewProvider {
//    static var previews: some View {
//        Todo_WidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//    }
//}
