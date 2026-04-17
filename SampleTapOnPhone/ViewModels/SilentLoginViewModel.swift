//
//  SilentLoginViewModel.swift
//  SampleTapOnPhone
//
//  Wraps the `TapOnPhoneSDK.operations.authenticationSilentLogin`
//  flow described in the SDK documentation (0.1.0-alpha-0).
//

import Foundation
import TapOnPhone

@MainActor
final class SilentLoginViewModel: ObservableObject {
    @Published var ssoToken: String = ""
    @Published var appToken: String = ""
    @Published var document: String = ""
    @Published var packageName: String = Bundle.main.bundleIdentifier ?? ""
    @Published var deviceName: String = ""
    @Published var nickName: String = ""
    @Published var user: String = ""
    @Published var expiresIn: Int = 3600

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    struct SilentLoginOutcome {
        let isSuccessful: Bool
        let message: String
        let terminalDescription: String
    }

    var canAuthenticate: Bool {
        !ssoToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !appToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !document.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !packageName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func authenticate() async -> SilentLoginOutcome? {
        guard canAuthenticate else { return nil }

        isLoading = true
        defer { isLoading = false }

        let tokens = AuthenticationTokens(
            ssoToken: ssoToken,
            expiresIn: expiresIn,
            creationDate: Date()
        )
        let parameters = SilentLoginParams(
            tokens: tokens,
            appToken: appToken,
            packageName: packageName,
            document: document,
            deviceName: deviceName.isEmpty ? nil : deviceName,
            nickName: nickName.isEmpty ? nil : nickName,
            user: user.isEmpty ? nil : user
        )

        let result = await TapOnPhoneSDK.operations.authenticationSilentLogin(parameters)

        if !result.isSuccessful {
            errorMessage = "[\(result.statusCode)] \(result.message)"
        }

        let terminalDescription = Self.describe(result.configuration)
        return SilentLoginOutcome(
            isSuccessful: result.isSuccessful,
            message: result.message,
            terminalDescription: terminalDescription
        )
    }

    private static func describe(_ configuration: ConfigurationLoginSDK?) -> String {
        guard let configuration else { return "" }
        var parts: [String] = []
        if let store = configuration.storeName, !store.isEmpty {
            parts.append(store)
        }
        if let terminal = configuration.codeTerminal, !terminal.isEmpty {
            parts.append("Terminal \(terminal)")
        }
        return parts.joined(separator: " • ")
    }
}
