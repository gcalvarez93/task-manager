//
//  ProfileViewModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/ViewModels/ProfileViewModel.swift
import Foundation
import Observation

enum ProfileState: Equatable {
    case initial
    case loading
    case loaded(ProfileEntity)
    case error(String)
}

@Observable
final class ProfileViewModel {
    var state: ProfileState = .initial
    var showEditProfile = false
    var showLanguagePicker = false

    private let getProfile: GetProfileUseCase
    private let updateProfile: UpdateProfileUseCase

    init(
        getProfile: GetProfileUseCase = GetProfileUseCase(repository: ProfileRepository()),
        updateProfile: UpdateProfileUseCase = UpdateProfileUseCase(repository: ProfileRepository())
    ) {
        self.getProfile = getProfile
        self.updateProfile = updateProfile
    }

    func loadProfile() async {
        state = .loading
        do {
            let profile = try await getProfile.execute()
            state = .loaded(profile)
        } catch {
            AppLogger.error("ProfileViewModel.loadProfile", error)
            state = .error(error.localizedDescription)
        }
    }

    /// Guarda el perfil en la API. Devuelve `true` si se guardó. Si falla,
    /// conserva el perfil que ya estaba cargado en lugar de pasar a `.error`,
    /// para que la pantalla de edición pueda avisar sin perder los datos.
    @discardableResult
    func update(name: String, language: String, notifications: Bool) async -> Bool {
        do {
            let profile = try await updateProfile.execute(
                name: name,
                language: language,
                notifications: notifications
            )
            state = .loaded(profile)
            return true
        } catch {
            AppLogger.error("ProfileViewModel.update", error)
            return false
        }
    }
}
