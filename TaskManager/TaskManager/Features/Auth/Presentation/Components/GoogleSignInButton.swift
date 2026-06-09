//
//  GoogleSignInButton.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Presentation/Components/GoogleSignInButton.swift
import SwiftUI

struct GoogleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "g.circle.fill")
                    .foregroundStyle(.red)
                Text("Google")
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}
