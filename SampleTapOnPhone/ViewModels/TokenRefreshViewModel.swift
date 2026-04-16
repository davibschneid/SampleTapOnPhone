//
//  TokenRefreshViewModel.swift
//  SampleTapOnPhone
//
//  Helper used by `AccountView` to push a refreshed access token to
//  the SDK via `TapOnPhoneSDK.operations.setAccessToken`.
//

import Foundation
import TapOnPhone

@MainActor
final class TokenRefreshViewModel: ObservableObject {
    @Published var ssoToken: String = ""
    @Published var expiresIn: Int = 3600
    @Published var alertMessage: String?

    /// Pushes the new token into the SDK. Returns whether the SDK
    /// accepted it.
    @discardableResult
    func refresh() -> Bool {
        let trimmed = ssoToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let tokens = AuthenticationTokens(
            ssoToken: trimmed,
            expiresIn: expiresIn,
            creationDate: Date()
        )
        let accepted = TapOnPhoneSDK.operations.setAccessToken(tokens)
        alertMessage = accepted
            ? "Novo accessToken aplicado com sucesso."
            : "A SDK não aceitou o novo token."
        if accepted {
            ssoToken = ""
        }
        return accepted
    }
}
