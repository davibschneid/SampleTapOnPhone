//
//  MonoECViewModel.swift
//  SampleTapOnPhone
//
//  Implements the MonoEC authentication flow documented in the SDK.
//  According to the documentation this method is intended only for
//  internal certifications — regular applications should rely on the
//  Silent Authentication flow instead.
//

import Foundation
import TapOnPhone

@MainActor
final class MonoECViewModel: ObservableObject {
    @Published var companyDocument: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var storeCode: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    struct MonoECOutcome {
        let isSuccessful: Bool
        let message: String
        let terminalDescription: String
    }

    var canAuthenticate: Bool {
        !companyDocument.isEmpty && !username.isEmpty && !password.isEmpty
    }

    func authenticate() async -> MonoECOutcome? {
        guard canAuthenticate else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            let parameters = MonoECAuthParameters(
                companyDocument: companyDocument,
                username: username,
                password: password,
                storeCode: storeCode.isEmpty ? nil : storeCode
            )
            let result = try await TapOnPhoneSDK.authentication.authenticateMonoEC(parameters)
            if !result.isSuccessful {
                errorMessage = "[\(result.statusCode)] \(result.message)"
            }
            return MonoECOutcome(
                isSuccessful: result.isSuccessful,
                message: result.message,
                terminalDescription: Self.describe(result.configuration)
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private static func describe(_ configuration: MonoECConfiguration?) -> String {
        guard let configuration else { return "" }
        var parts: [String] = []
        if let store = configuration.storeName, !store.isEmpty {
            parts.append(store)
        }
        if let terminal = configuration.terminalCode, !terminal.isEmpty {
            parts.append("Terminal \(terminal)")
        }
        return parts.joined(separator: " • ")
    }
}
