//
//  TasksView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Views/TasksView.swift
import SwiftUI

struct TasksView: View {
    let board: BoardEntity

    var body: some View {
        Text(board.name)
            .navigationTitle(board.name)
    }
}
