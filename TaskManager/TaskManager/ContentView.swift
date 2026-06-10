//
//  ContentView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var themeManager = ThemeManager()

    var body: some View {
        Group {
            switch authViewModel.state {
            case .initial, .loading:
                ProgressView()
            case .authenticated:
                HomeView()
            case .unauthenticated, .error:
                LoginView()
            }
        }
        .environment(authViewModel)
        .environment(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
    }
}
