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
            print("❌ Widget Failed to fetch days in snapshot")
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
            print("❌ Widget Failed to fetch days in snapshot")
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
    @ObservedObject var viewModel = WidgetViewModel()
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            Gauge(value: calculateGaugeValue()) {
                Text("완료")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack {
                ForEach(validateLenghtForLockscreen(), id: \.self) { todo in
                    HStack {
                        Image(systemName: "square")
                        Text(todo.title ?? "")
                        Spacer()
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
        default:
            VStack {
                ForEach(validateLenghtForWidget(), id: \.self) { todo in
                    HStack {
                        Image(systemName: "square")
                        Text(todo.title ?? "")
                        Spacer()
                    }
                    .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
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
        .supportedFamilies([.accessoryRectangular, .systemMedium, .systemLarge, .accessoryCircular])
    }
}

//struct Todo_Widget_Previews: PreviewProvider {
//    static var previews: some View {
//        Todo_WidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//        Todo_WidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//        Todo_WidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//    }
//}
