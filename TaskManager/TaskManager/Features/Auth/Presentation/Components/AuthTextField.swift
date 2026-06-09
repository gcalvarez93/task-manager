//
//  AuthTextField.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Presentation/Components/AuthTextField.swift
import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}
