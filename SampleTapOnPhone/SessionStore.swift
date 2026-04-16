//
//  SessionStore.swift
//  SampleTapOnPhone
//
//  Lightweight observable object that keeps track of the
//  authentication state across the app.
//

import Foundation
import Combine

/// Holds the state that is shared between the authentication flow
/// and the transaction screens.
final class SessionStore: ObservableObject {
    /// Whether the user completed a successful authentication with the SDK.
    @Published var isAuthenticated: Bool = false

    /// Human-friendly description of the authenticated terminal/store.
    /// Populated after a successful Silent Login.
    @Published var terminalDescription: String = ""

    /// Tokens that were issued by the backend and forwarded to the SDK.
    /// Persisted so the UI can refresh them when they expire.
    @Published var lastAccessTokenCreatedAt: Date?

    func logout() {
        isAuthenticated = false
        terminalDescription = ""
        lastAccessTokenCreatedAt = nil
    }
}
