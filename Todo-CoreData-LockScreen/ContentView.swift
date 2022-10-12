//
//  ContentView.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel = ContenViewModel()

    var body: some View {
        List {
            Section("투두 추가") {
                HStack {
                    TextField("입력", text: $viewModel.userInput) {
                        viewModel.didSubmitTextField()
                    }
                    Spacer()
                }
            }
            Section("진행중 투두") {
                ForEach(viewModel.inProgressTodoList, id: \.self) { todo in
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.didTapTodo(todo: todo)
                            }
                        } label: {
                            Image(systemName: "square")

                        }
                        Text(todo.title ?? "")
                    }
                    .foregroundColor(.black)
                    .opacity(0.8)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            withAnimation {
                                viewModel.didSwipeTodo(todo: todo)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            Section("완료된 투두") {
                ForEach(viewModel.doneTodoList, id: \.self) { todo in
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.didTapTodo(todo: todo)
                            }
                        } label: {
                            Image(systemName: "checkmark.square")
                        }
                        Text(todo.title ?? "")
                            .strikethrough()
                    }
                    .foregroundColor(.black)
                    .opacity(0.4)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            withAnimation {
                                viewModel.didSwipeTodo(todo: todo)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }

                }
            }
        }
        .onChange(of: scenePhase, perform: { newValue in
            switch newValue {
            case .active:
                WidgetCenter.shared.reloadAllTimelines()
            case .background:
                WidgetCenter.shared.reloadAllTimelines()
            default:
                WidgetCenter.shared.reloadAllTimelines()
            }
        })
    }
}
