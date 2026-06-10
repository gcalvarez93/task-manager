//
//  ProfileOptionRow.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/Components/ProfileOptionRow.swift
import SwiftUI

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    var value: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.body)

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    List {
        ProfileOptionRow(icon: "person", title: "Edit Profile", color: .blue)
        ProfileOptionRow(icon: "bell", title: "Notifications", color: .orange)
        ProfileOptionRow(icon: "globe", title: "Language", color: .green, value: "Español")
    }
}
