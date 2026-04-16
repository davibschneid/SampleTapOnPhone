//
//  AuthenticationView.swift
//  SampleTapOnPhone
//
//  Screen that lets the user choose between the recommended Silent
//  Login flow and the MonoEC flow (used only for internal
//  certifications, as noted in the SDK documentation).
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var silentVM = SilentLoginViewModel()
    @StateObject private var monoECVM = MonoECViewModel()
    @EnvironmentObject private var session: SessionStore

    enum Mode: String, CaseIterable, Identifiable {
        case silent = "Silent Login"
        case monoEC = "MonoEC"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .silent

    var body: some View {
        Form {
            Section {
                Picker("Método", selection: $mode) {
                    ForEach(Mode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Silent Login é o método recomendado. MonoEC é utilizado apenas em cenários de certificação interna.")
            }

            switch mode {
            case .silent:
                silentLoginSection
            case .monoEC:
                monoECSection
            }
        }
        .navigationTitle("Autenticação")
        .alert("Falha na autenticação", isPresented: alertBinding) {
            Button("OK", role: .cancel) { clearError() }
        } message: {
            Text(currentErrorMessage ?? "")
        }
    }

    // MARK: - Silent Login

    private var silentLoginSection: some View {
        Group {
            Section("SSO Access Token") {
                TextField("ssoToken (v1/tef-embarcado/oauth/token)", text: $silentVM.ssoToken, axis: .vertical)
                    .lineLimit(1...4)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Stepper(value: $silentVM.expiresIn, in: 60...86_400, step: 60) {
                    Text("Expira em: \(silentVM.expiresIn) s")
                }
            }

            Section("App Token") {
                TextField("appToken (v1/tef-embarcado/top-auth-adp/app-token)", text: $silentVM.appToken, axis: .vertical)
                    .lineLimit(1...4)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Identificação") {
                TextField("Documento (CPF / CNPJ)", text: $silentVM.document)
                    .keyboardType(.numberPad)
                TextField("Bundle Identifier", text: $silentVM.packageName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Nome do dispositivo (opcional)", text: $silentVM.deviceName)
                TextField("Nickname (opcional)", text: $silentVM.nickName)
                TextField("Usuário (opcional)", text: $silentVM.user)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section {
                Button {
                    Task { await performSilentLogin() }
                } label: {
                    HStack {
                        Spacer()
                        if silentVM.isLoading {
                            ProgressView()
                        } else {
                            Text("Entrar")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!silentVM.canAuthenticate || silentVM.isLoading)
            }
        }
    }

    // MARK: - MonoEC

    private var monoECSection: some View {
        Group {
            Section("Credenciais") {
                TextField("Documento da empresa", text: $monoECVM.companyDocument)
                    .keyboardType(.numberPad)
                TextField("Usuário", text: $monoECVM.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Senha", text: $monoECVM.password)
                TextField("Código da loja (opcional)", text: $monoECVM.storeCode)
            }

            Section {
                Button {
                    Task { await performMonoECLogin() }
                } label: {
                    HStack {
                        Spacer()
                        if monoECVM.isLoading {
                            ProgressView()
                        } else {
                            Text("Entrar")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!monoECVM.canAuthenticate || monoECVM.isLoading)
            }
        }
    }

    // MARK: - Helpers

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { currentErrorMessage != nil },
            set: { if !$0 { clearError() } }
        )
    }

    private var currentErrorMessage: String? {
        switch mode {
        case .silent: return silentVM.errorMessage
        case .monoEC: return monoECVM.errorMessage
        }
    }

    private func clearError() {
        silentVM.errorMessage = nil
        monoECVM.errorMessage = nil
    }

    private func performSilentLogin() async {
        let result = await silentVM.authenticate()
        guard let result, result.isSuccessful else { return }
        session.isAuthenticated = true
        session.terminalDescription = result.terminalDescription
        session.lastAccessTokenCreatedAt = Date()
    }

    private func performMonoECLogin() async {
        let result = await monoECVM.authenticate()
        guard let result, result.isSuccessful else { return }
        session.isAuthenticated = true
        session.terminalDescription = result.terminalDescription
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
    .environmentObject(SessionStore())
}
