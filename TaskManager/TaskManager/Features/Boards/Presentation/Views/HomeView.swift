//
//  HomeView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Presentation/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab(String(localized: "nav_boards"), systemImage: "square.grid.2x2") {
                BoardsView()
            }
            Tab(String(localized: "nav_profile"), systemImage: "person") {
                Text("Profile")
            }
        }
    }
}
