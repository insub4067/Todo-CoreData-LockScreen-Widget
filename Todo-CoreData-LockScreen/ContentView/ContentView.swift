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
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        List {
            addTodoSection
            inProgressTodoListSection
            doneTodoListSection
        }
        .listStyle(.inset)
        .onChange(of: scenePhase, perform: { newValue in
            WidgetCenter.shared.reloadAllTimelines()
        })
    }
}

private extension ContentView {
    var addTodoSection: some View {
        Section("추가") {
            HStack {
                TextField("입력", text: $viewModel.userInput) {
                    viewModel.didSubmitTextField()
                }
                Spacer()
                Image(systemName: "x.circle")
                    .onTapGesture {
                        viewModel.didTapXbutton()
                    }
                    .opacity(0.6)
                    .font(.subheadline)
            }
        }
    }

    var inProgressTodoListSection: some View {
        Section("진행중") {
            ForEach(viewModel.inProgressTodoList, id: \.self) { todo in
                HStack(spacing: 4) {
                    Button {
                        withAnimation {
                            viewModel.didTapTodo(todo: todo)
                        }
                    } label: {
                        Image(systemName: "square")
                            .font(.caption)
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
    }

    var doneTodoListSection: some View {
        Section("완료") {
            ForEach(viewModel.doneTodoList, id: \.self) { todo in
                HStack(spacing: 4) {
                    Button {
                        withAnimation {
                            viewModel.didTapTodo(todo: todo)
                        }
                    } label: {
                        Image(systemName: "checkmark.square")
                            .font(.caption)
                    }
                    Text(todo.title ?? "")
                        .strikethrough()
                }
                .foregroundColor(.black)
                .opacity(0.6)
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
}
