//
//  ContentView.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel = ContenViewModel()

    var body: some View {
        List {
            Section("투두 추가") {
                HStack {
                    TextField("입력", text: $viewModel.userInput) {
                        viewModel.didSubmitTextField(context: managedObjectContext)
                    }
                    Spacer()
                }
            }
            Section("진행중 투두") {
                ForEach(viewModel.inProgressTodoList, id: \.self) { todo in
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.didTapTodo(todo: todo, context: managedObjectContext)
                            }
                        } label: {
                            Image(systemName: "square")

                        }
                        Text(todo.title ?? "")
                    }
                    .foregroundColor(.black)
                    .opacity(0.8)
                }
            }
            Section("완료된 투두") {
                ForEach(viewModel.doneTodoList, id: \.self) { todo in
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.didTapTodo(todo: todo, context: managedObjectContext)
                            }
                        } label: {
                            Image(systemName: "checkmark.square")
                        }
                        Text(todo.title ?? "")
                            .strikethrough()
                    }
                    .foregroundColor(.black)
                    .opacity(0.4)

                }
            }
        }
        .onAppear {
            viewModel.getAllTodos(context: managedObjectContext)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
