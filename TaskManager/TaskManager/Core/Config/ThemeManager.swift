//
//  ThemeManager.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Core/Config/ThemeManager.swift
import SwiftUI
import Observation

@Observable
final class ThemeManager {
    var colorScheme: ColorScheme? = nil // nil = system

    var selectedTheme: AppTheme {
        get {
            switch colorScheme {
            case .dark: return .dark
            case .light: return .light
            default: return .system
            }
        }
        set {
            switch newValue {
            case .system: colorScheme = nil
            case .light:  colorScheme = .light
            case .dark:   colorScheme = .dark
            }
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: return String(localized: "theme_system")
        case .light:  return String(localized: "theme_light")
        case .dark:   return String(localized: "theme_dark")
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }
}
