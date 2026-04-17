//
//  AccountView.swift
//  SampleTapOnPhone
//
//  Shows the session information and exposes the access-token refresh
//  utility described in the SDK documentation ("Token Update").
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = TokenRefreshViewModel()

    var body: some View {
        Form {
            Section("Sessão") {
                LabeledContent("Terminal") {
                    Text(session.terminalDescription.isEmpty
                         ? "—"
                         : session.terminalDescription)
                }
                LabeledContent("Token emitido em") {
                    Text(session.lastAccessTokenCreatedAt
                            .map { $0.formatted(date: .numeric, time: .standard) }
                            ?? "—")
                }
            }

            Section {
                TextField("Novo ssoToken", text: $viewModel.ssoToken, axis: .vertical)
                    .lineLimit(1...4)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Stepper(value: $viewModel.expiresIn, in: 60...86_400, step: 60) {
                    Text("Expira em: \(viewModel.expiresIn) s")
                }
                Button {
                    if viewModel.refresh() {
                        session.lastAccessTokenCreatedAt = Date()
                    }
                } label: {
                    Text("Aplicar novo token")
                }
                .disabled(viewModel.ssoToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text("Atualizar accessToken")
            } footer: {
                Text("Use este método após a exceção AuthenticationError.tokenExpired.")
            }

            Section {
                Button(role: .destructive) {
                    session.logout()
                } label: {
                    Text("Sair")
                }
            }
        }
        .navigationTitle("Conta")
        .alert("Atualização de token", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.alertMessage = nil }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack { AccountView() }
        .environmentObject({
            let s = SessionStore()
            s.isAuthenticated = true
            s.terminalDescription = "Loja Demo • Terminal 00000001"
            s.lastAccessTokenCreatedAt = Date()
            return s
        }())
}
