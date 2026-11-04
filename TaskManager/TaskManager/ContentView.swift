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
            case .initial:
                ProgressView()
            case .authenticated:
                HomeView()
            case .loading, .unauthenticated, .error:
                // `.loading` mantiene el login en pantalla: si se sustituyera por un spinner,
                // se perderían los campos escritos y el aviso de error no llegaría a verse.
                LoginView()
            }
        }
        .environment(authViewModel)
        .environment(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
    }
}
